import { getModels, type Api, type Model } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type ProviderModel = Model<Api>;

function toProviderModel(model: ProviderModel): ProviderModel {
  return {
    id: model.id,
    name: model.name,
    api: model.api,
    baseUrl: model.baseUrl,
    reasoning: model.reasoning,
    thinkingLevelMap: model.thinkingLevelMap,
    input: model.input,
    cost: model.cost,
    contextWindow: model.contextWindow,
    maxTokens: model.maxTokens,
    compat: model.compat,
    headers: model.headers,
  };
}

export default function (pi: ExtensionAPI) {
  const freeModels = getModels("opencode")
    .filter((model) => model.id.toLowerCase().includes("free"))
    .map(toProviderModel);

  pi.registerProvider("opencode", {
    name: "OpenCode Zen",
    baseUrl: "https://opencode.ai/zen/v1",
    apiKey: "$OPENCODE_API_KEY",
    api: "openai-completions",
    authHeader: true,
    models: freeModels,
  });
}
