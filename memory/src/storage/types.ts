export interface MemoryEntry {
  id: string;
  content: string;
  tags: string[];
  project: string | null;
  createdAt: number;
  embeddingModel: string;
}

export interface VectorEntry {
  id: string;
  vector: number[];
  content: string;
}

export interface SearchResult extends MemoryEntry {
  score: number;
}

export const EMBEDDING_MODELS = {
  "nomic-embed-text": { dimensions: 768, family: "nomic-bert" },
  "mxbai-embed-large": { dimensions: 1024, family: "bert" },
  "embeddinggemma": { dimensions: 768, family: "gemma3" }
} as const;

export type ModelName = keyof typeof EMBEDDING_MODELS;

export const DEFAULT_MODEL: ModelName = "nomic-embed-text";
