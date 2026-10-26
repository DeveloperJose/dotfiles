/**
 * Local Server Model Discovery Extension
 *
 * Discovers models from any reachable local OpenAI-compatible inference
 * servers and registers them as pi providers. Each live server becomes its
 * own provider so the one you actually started is the one pi can use.
 *
 * Supported servers (add more to LOCAL_SERVERS):
 *   - llama.cpp / llama-cpp-turboquant (start-llama-server.sh, :8080)
 *   - FreeToken (start-freetoken-server.sh, :1919)
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface LocalServerConfig {
  id: string;
  name: string;
  baseUrl: string;
}

interface LlamaModel {
  id: string;
  object: string;
  created: number;
  owned_by: string;
  max_model_len?: number | null;
  context_length?: number | null;
  meta?: {
    n_ctx?: number | null;
    n_ctx_train?: number;
    n_embd?: number;
    n_params?: number;
    size?: number;
    vocab_type?: number;
  };
}

interface PropsResponse {
  default_generation_settings?: {
    n_ctx?: number;
  };
}

interface ModelsResponse {
  data: LlamaModel[];
}

const LOCAL_SERVERS: LocalServerConfig[] = [
  { id: "llama-server", name: "Llama.cpp Server", baseUrl: "http://127.0.0.1:8080" },
  { id: "freetoken-server", name: "FreeToken Server", baseUrl: "http://127.0.0.1:1919" },
];

const DEFAULT_CONTEXT_WINDOW = 128000;

async function fetchModels(baseUrl: string): Promise<LlamaModel[]> {
  // Prefer the OpenAI-compatible /v1/models endpoint (FreeToken, modern
  // llama.cpp); fall back to llama.cpp's legacy /models for older builds.
  for (const path of ["/v1/models", "/models"]) {
    try {
      const res = await fetch(`${baseUrl}${path}`);
      if (!res.ok) continue;
      const data: ModelsResponse = await res.json();
      const models = data.data || [];
      if (models.length > 0) return models;
    } catch {
      // server down or unreachable — try next endpoint
    }
  }
  return [];
}

async function getServerContextWindow(baseUrl: string): Promise<number | undefined> {
  try {
    const res = await fetch(`${baseUrl}/props`);
    if (!res.ok) return undefined;
    const data: PropsResponse = await res.json();
    return data.default_generation_settings?.n_ctx;
  } catch {
    return undefined;
  }
}

async function discoverServer(server: LocalServerConfig) {
  const [models, serverCtx] = await Promise.all([
    fetchModels(server.baseUrl),
    getServerContextWindow(server.baseUrl),
  ]);
  if (models.length === 0) return null;

  const providerModels = models.map((model) => {
    // Actual serving context: /props n_ctx (llama.cpp) > FreeToken's
    // per-model context_length/max_model_len > GGUF n_ctx_train > default.
    const contextWindow =
      serverCtx ??
      model.meta?.n_ctx ??
      model.context_length ??
      model.max_model_len ??
      model.meta?.n_ctx_train ??
      DEFAULT_CONTEXT_WINDOW;
    return {
      id: model.id,
      name: model.id.split("/").pop() || model.id,
      reasoning: true,
      input: ["text"] as ("text" | "image")[],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow,
      maxTokens: 8192,
      // Local OpenAI-compatible servers (llama.cpp / FreeToken) reject the
      // "developer" role; keep the system prompt as role "system" and avoid
      // OpenAI-only request fields they don't understand.
      compat: {
        supportsStore: false,
        supportsDeveloperRole: false,
        supportsReasoningEffort: false,
        supportsUsageInStreaming: true,
        supportsStrictMode: false,
        maxTokensField: "max_tokens",
      },
    };
  });

  return {
    id: server.id,
    name: server.name,
    baseUrl: `${server.baseUrl}/v1`,
    api: "openai-completions",
    apiKey: "none",
    models: providerModels,
  };
}

export default async function (pi: ExtensionAPI) {
  const results = await Promise.all(LOCAL_SERVERS.map(discoverServer));

  for (const provider of results) {
    if (!provider) continue;
    pi.registerProvider(provider.id, provider);
    console.log(
      `[local-server-discovery] Registered ${provider.models.length} model(s) from ${provider.name}`,
    );
  }
}