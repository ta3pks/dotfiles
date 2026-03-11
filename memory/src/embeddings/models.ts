export const EMBEDDING_MODELS = {
  "nomic-embed-text": { dimensions: 768, family: "nomic-bert" },
  "mxbai-embed-large": { dimensions: 1024, family: "bert" },
  "embeddinggemma": { dimensions: 768, family: "gemma3" }
} as const;

export type ModelName = keyof typeof EMBEDDING_MODELS;

export const DEFAULT_MODEL: ModelName = "nomic-embed-text";

export function getModelConfig(model: ModelName) {
  return EMBEDDING_MODELS[model];
}

export function getDimensions(model: ModelName): number {
  return EMBEDDING_MODELS[model].dimensions;
}
