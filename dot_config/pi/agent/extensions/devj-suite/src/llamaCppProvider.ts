import { join } from "path";
import { homedir } from "os";
import { readFileSync, existsSync } from "fs";
import {
  ModelRegistry,
  AuthStorage,
  ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { type Model, type Api } from "@mariozechner/pi-ai";

interface ModelsConfig {
  providers: {
    [key: string]: {
      baseUrl?: string;
      api?: Api;
      apiKey?: string;
      headers?: Record<string, string>;
    };
  };
}

interface LlamaCppModel {
  id: string;
  object: string;
  created: number;
  owned_by: string;
  status: {
    value: string;
    args: string[];
    preset: string;
  };
  meta?: {
    n_ctx_train?: number;
    n_embd?: number;
    [key: string]: unknown;
  };
}

interface LlamaCppModelsResponse {
  data: LlamaCppModel[];
  object: string;
}

export async function activateLlamaCppProvider(pi: ExtensionAPI): Promise<void> {
  const modelRegistry = pi.modelRegistry;
  const providerName = "llama.cpp";
  const modelsJsonPath = join(homedir(), ".config", "pi", "agent", "models.json");
  let providerConfig: ModelsConfig["providers"]["llama.cpp"] | undefined;

  if (existsSync(modelsJsonPath)) {
    try {
      const modelsConfig: ModelsConfig = JSON.parse(readFileSync(modelsJsonPath, "utf-8"));
      providerConfig = modelsConfig.providers?.[providerName];
    } catch (error) {
      console.error(`Error parsing models.json:`, error);
    }
  }

  if (!providerConfig?.baseUrl) {
    console.warn(
      `Llama.cpp provider not configured in models.json. Skipping auto-discovery.`,
    );
  } else {
    try {
      const baseUrl = providerConfig.baseUrl.endsWith("/v1") ? providerConfig.baseUrl.slice(0, -3) : providerConfig.baseUrl;
      const url = `${baseUrl}/models`;
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error(
          `Failed to fetch models from llama.cpp: ${response.statusText}`,
        );
      }

      const data = (await response.json()) as LlamaCppModelsResponse;
      if (!data.data) {
        throw new Error("Invalid response format: missing 'data' array");
      }

      const models: Model<Api>[] = data.data
        .filter((llamaModel) => llamaModel.id !== "default")
        .map((llamaModel) => {
          const meta = llamaModel.meta || {};
          let contextWindow = 4096;
          const ctxSizeIndex = llamaModel.status.args.indexOf("--ctx-size");
          if (ctxSizeIndex !== -1 && ctxSizeIndex + 1 < llamaModel.status.args.length) {
            const ctxSize = parseInt(llamaModel.status.args[ctxSizeIndex + 1]);
            if (!isNaN(ctxSize)) {
              contextWindow = ctxSize;
            }
          }
          
          const maxTokens = Math.floor(contextWindow * 0.75); // Use 75% of context window as max tokens
          
          return {
            id: llamaModel.id,
            name: llamaModel.id,
            provider: providerName,
            api: providerConfig.api || "openai-completions", // Default to openai-completions
            baseUrl: providerConfig.baseUrl!,
            reasoning: false,
            input: ["text"],
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, // Free local model
            contextWindow: Math.floor(contextWindow),
            maxTokens: maxTokens,
            headers: providerConfig.headers,
          };
        });

      pi.registerProvider(providerName, {
        ...providerConfig,
        models: models,
      });
      console.log(`Discovered ${models.length} models from llama.cpp`);
    } catch (error) {
      console.error(`Error discovering llama.cpp models:`, error);
    }
  }
}
