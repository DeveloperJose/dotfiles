import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export function activateExitAlias(pi: ExtensionAPI) {
  pi.registerCommand("exit", {
    description: "Exit pi cleanly (alias for /quit)",
    handler: async (_args, ctx) => {
      ctx.shutdown();
    },
  });
}