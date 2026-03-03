/**
 * Exit Alias Module
 *
 * Registers a /exit command as an alias for the built-in /quit command.
 * This allows you to use either /quit or /exit to exit Pi cleanly.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function exitAliasExtension(pi: ExtensionAPI) {
  // Register a /exit command that does the same as /quit
  pi.registerCommand("exit", {
    description: "Exit pi cleanly (alias for /quit)",
    handler: async (_args, ctx) => {
      ctx.shutdown();
    },
  });
}