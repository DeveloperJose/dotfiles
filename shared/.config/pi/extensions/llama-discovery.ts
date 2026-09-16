/**
 * Llama Model Discovery Extension
 *
 * Discovers models from llama.cpp server /models endpoint and registers them.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface LlamaModel {
  id: string;
  object: string;
  created: number;
  owned_by: string;
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

interface LlamaModelsResponse {
  data: LlamaModel[];
}

const LLAMA_URL = "http://127.0.0.1:8080";

async function discoverModels(): Promise<LlamaModel[]> {
  try {
    const res = await fetch(`${LLAMA_URL}/models`);
    if (!res.ok) return [];
    const data: LlamaModelsResponse = await res.json();
    return data.data || [];
  } catch {
    return [];
  }
}

async function getServerContextWindow(): Promise<number | undefined> {
  try {
    const res = await fetch(`${LLAMA_URL}/props`);
    if (!res.ok) return undefined;
    const data: PropsResponse = await res.json();
    return data.default_generation_settings?.n_ctx;
  } catch {
    return undefined;
  }
}

export default async function (pi: ExtensionAPI) {
  const models = await discoverModels();
  const serverCtx = await getServerContextWindow();

  const providerModels = models.map((model) => {
    // Use actual serving context from /props (n_ctx), not GGUF training context (n_ctx_train)
    const contextWindow = serverCtx ?? model.meta?.n_ctx ?? model.meta?.n_ctx_train ?? 128000;
    return {
      id: model.id,
      name: model.id.split("/").pop() || model.id,
      reasoning: true,
      input: ["text"] as ("text" | "image")[],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow,
      maxTokens: 8192,
    };
  });

  pi.registerProvider("llama-server", {
    name: "Llama.cpp Server",
    baseUrl: `${LLAMA_URL}/v1`,
    api: "openai-completions",
    apiKey: "none",
    models: providerModels,
  });

  console.log(`[llama-discovery] Registered ${models.length} models from llama.cpp server`);
}