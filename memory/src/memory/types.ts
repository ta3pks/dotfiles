import type { ModelName } from "../embeddings/models.js";

export interface CreateMemoryInput {
  content: string;
  tags?: string[];
  project?: string;
  model?: ModelName;
}

export interface MemorySearchResult {
  id: string;
  content: string;
  tags: string[];
  project: string | null;
  createdAt: number;
  embeddingModel: string;
  score: number;
}

export interface MemoryServiceConfig {
  dataPath?: string;
  defaultModel?: ModelName;
}
