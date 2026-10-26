import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, isAbsolute, join } from "node:path";

type SkillConfig = {
  name: string;
  path?: string;
  heading?: string;
  extra?: string;
  enabled?: boolean;
};

type Config = {
  enabled?: boolean;
  skills?: Array<string | SkillConfig>;
};

const CONFIG_DIR = process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
const CONFIG_PATH = join(CONFIG_DIR, "default-skills.json");

function expandPath(path: string): string {
  if (path === "~") return homedir();
  if (path.startsWith("~/")) return join(homedir(), path.slice(2));
  if (isAbsolute(path)) return path;
  return join(CONFIG_DIR, path);
}

function defaultSkillPath(name: string): string | undefined {
  const candidates = [
    join(CONFIG_DIR, "skills", name, "SKILL.md"),
    join(homedir(), ".agents", "skills", name, "SKILL.md"),
    join(homedir(), ".pi", "agent", "skills", name, "SKILL.md"),
  ];
  return candidates.find(existsSync);
}

function stripFrontmatter(markdown: string): string {
  return markdown.replace(/^---[\s\S]*?---\s*/, "").trim();
}

function slug(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9-]+/g, "-").replace(/^-+|-+$/g, "");
}

function normalizeSkill(entry: string | SkillConfig): SkillConfig {
  if (typeof entry === "string") return { name: entry };
  return entry;
}

function loadConfig(): Config {
  if (!existsSync(CONFIG_PATH)) {
    const initial: Config = { enabled: true, skills: [] };
    mkdirSync(dirname(CONFIG_PATH), { recursive: true });
    writeFileSync(CONFIG_PATH, JSON.stringify(initial, null, 2) + "\n");
    return initial;
  }
  return JSON.parse(readFileSync(CONFIG_PATH, "utf8")) as Config;
}

function saveConfig(config: Config) {
  mkdirSync(dirname(CONFIG_PATH), { recursive: true });
  writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2) + "\n");
}

function resolveSkill(skill: SkillConfig, pi?: ExtensionAPI): { name: string; heading: string; content: string } | { name: string; error: string } {
  const command = pi
    ?.getCommands()
    .find((cmd) => cmd.source === "skill" && (cmd.name === `skill:${skill.name}` || cmd.name === skill.name));
  const commandPath = command?.sourceInfo?.path;
  const path = skill.path ? expandPath(skill.path) : commandPath || defaultSkillPath(skill.name);
  if (!path) return { name: skill.name, error: `Skill not found: ${skill.name}` };
  if (!existsSync(path)) return { name: skill.name, error: `Skill path missing: ${path}` };

  const body = stripFrontmatter(readFileSync(path, "utf8"));
  const heading = skill.heading || `Default Skill: ${skill.name}`;
  const extra = skill.extra ? `${skill.extra}\n\n` : "";
  return { name: skill.name, heading, content: `${extra}${body}`.trim() };
}

function enabledSkills(config: Config): SkillConfig[] {
  return (config.skills || []).map(normalizeSkill).filter((skill) => skill.enabled !== false);
}

function skillNames(config: Config): string[] {
  return enabledSkills(config).map((skill) => skill.name);
}

export default function (pi: ExtensionAPI) {
  let config = loadConfig();

  function reloadConfig() {
    config = loadConfig();
  }

  function statusText() {
    if (config.enabled === false) return "defaults:off";
    const names = skillNames(config);
    return names.length ? `defaults:${names.join(",")}` : "defaults:none";
  }

  pi.on("session_start", async (_event, ctx) => {
    reloadConfig();
    ctx.ui.setStatus("default-skills", statusText());
  });

  pi.on("input", async (event, ctx) => {
    const text = event.text.trim().toLowerCase();
    if (text === "/default-skills reload") {
      reloadConfig();
      ctx.ui.setStatus("default-skills", statusText());
    }
    return { action: "continue" as const };
  });

  pi.on("before_agent_start", async (event) => {
    reloadConfig();
    if (config.enabled === false) return;

    const sections: string[] = [];
    for (const skill of enabledSkills(config)) {
      const resolved = resolveSkill(skill, pi);
      if ("error" in resolved) {
        sections.push(`# Default Skill Error: ${resolved.name}\n\n${resolved.error}`);
      } else {
        sections.push(`# ${resolved.heading}\n\n${resolved.content}`);
      }
    }
    if (sections.length === 0) return;

    return {
      systemPrompt:
        event.systemPrompt +
        "\n\n# Default Context Skills\n\nThe following skills are enabled by default for this session. Follow them unless higher-priority instructions conflict.\n\n" +
        sections.join("\n\n"),
    };
  });

  pi.registerCommand("default-skills", {
    description: "Manage default context skills: list|add <name|path>|remove <name>|on|off|reload",
    handler: async (args, ctx) => {
      reloadConfig();
      const [cmdRaw, ...rest] = args.trim().split(/\s+/).filter(Boolean);
      const cmd = (cmdRaw || "list").toLowerCase();
      const value = rest.join(" ");

      if (cmd === "list") {
        ctx.ui.notify(`${statusText()}\nConfig: ${CONFIG_PATH}`, "info");
        return;
      }

      if (cmd === "on") {
        config.enabled = true;
        saveConfig(config);
      } else if (cmd === "off") {
        config.enabled = false;
        saveConfig(config);
      } else if (cmd === "reload") {
        reloadConfig();
      } else if (cmd === "add" && value) {
        const name = value.endsWith(".md") || value.includes("/") ? slug(value.split("/").filter(Boolean).slice(-2, -1)[0] || value) : value;
        const skill: SkillConfig = value.endsWith(".md") || value.includes("/") ? { name, path: value } : { name: value };
        const current = (config.skills || []).map(normalizeSkill).filter((s) => s.name !== skill.name);
        current.push(skill);
        config.skills = current;
        config.enabled = true;
        saveConfig(config);
      } else if (cmd === "remove" && value) {
        config.skills = (config.skills || []).map(normalizeSkill).filter((skill) => skill.name !== value);
        saveConfig(config);
      } else {
        ctx.ui.notify("Usage: /default-skills list|add <name|path>|remove <name>|on|off|reload", "error");
        return;
      }

      ctx.ui.setStatus("default-skills", statusText());
      ctx.ui.notify(`${statusText()}\nConfig: ${CONFIG_PATH}`, "info");
    },
  });
}