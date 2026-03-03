import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { activateLlamaCppProvider } from "./src/llamaCppProvider";
import { activateExitAlias } from "./src/exitAlias";

export default function activate(pi: ExtensionAPI) {
  console.log("Activating DevJ Workflow Suite...");

  // Activate Llama.cpp provider
  activateLlamaCppProvider(pi);

  // Activate exit alias
  activateExitAlias(pi);

  console.log("DevJ Workflow Suite activated.");
}
