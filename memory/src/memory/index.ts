import { nanoid } from "nanoid";
import { getEmbedding, checkOllamaHealth, type ModelName, DEFAULT_MODEL, getDimensions } from "../embeddings/index.js";
import { initVectorStore, addVector, searchSimilar, closeVectorStore } from "../storage/lancedb.js";
import { initMetaStore, insertMemory, getMemory, listMemories, deleteMemory, closeMetaStore } from "../storage/sqlite.js";
import type { MemoryEntry, VectorEntry } from "../storage/types.js";
import type { CreateMemoryInput, MemorySearchResult, MemoryServiceConfig } from "./types.js";

let initialized = false;
let currentModel: ModelName = DEFAULT_MODEL;

export async function initMemoryService(config: MemoryServiceConfig = {}): Promise<void> {
  const dataPath = config.dataPath || "./data";
  currentModel = config.defaultModel || DEFAULT_MODEL;
  
  const healthy = await checkOllamaHealth();
  if (!healthy) {
    throw new Error("Ollama is not running. Start Ollama service first.");
  }
  
  await initVectorStore(`${dataPath}/vectors`, currentModel);
  initMetaStore(`${dataPath}/metadata.sqlite`);
  
  initialized = true;
}

export function isInitialized(): boolean {
  return initialized;
}

export async function storeMemory(input: CreateMemoryInput): Promise<string> {
  if (!initialized) {
    throw new Error("Memory service not initialized. Call initMemoryService first.");
  }
  
  const model = input.model || currentModel;
  const id = nanoid(12);
  const now = Date.now();
  
  const embeddingResult = await getEmbedding(input.content, model);
  
  const entry: MemoryEntry = {
    id,
    content: input.content,
    tags: input.tags || [],
    project: input.project || null,
    createdAt: now,
    embeddingModel: model
  };
  
  const vectorEntry: VectorEntry = {
    id,
    vector: embeddingResult.embedding,
    content: input.content
  };
  
  insertMemory(entry);
  await addVector(vectorEntry);
  
  return id;
}

export async function searchMemories(
  query: string,
  options: {
    limit?: number;
    model?: ModelName;
  } = {}
): Promise<MemorySearchResult[]> {
  if (!initialized) {
    throw new Error("Memory service not initialized.");
  }
  
  const model = options.model || currentModel;
  const limit = options.limit || 10;
  
  const embeddingResult = await getEmbedding(query, model);
  
  const vectorResults = await searchSimilar(embeddingResult.embedding, limit);
  
  const results: MemorySearchResult[] = [];
  for (const vr of vectorResults) {
    if (vr.id === "init") continue;
    
    const metadata = getMemory(vr.id);
    if (metadata) {
      results.push({
        ...metadata,
        score: vr.score
      });
    }
  }
  
  return results;
}

export function retrieveMemory(id: string): MemoryEntry | null {
  if (!initialized) {
    throw new Error("Memory service not initialized.");
  }
  return getMemory(id);
}

export function listAllMemories(options: {
  project?: string;
  tag?: string;
  limit?: number;
} = {}): MemoryEntry[] {
  if (!initialized) {
    throw new Error("Memory service not initialized.");
  }
  return listMemories(options);
}

export async function removeMemory(id: string): Promise<boolean> {
  if (!initialized) {
    throw new Error("Memory service not initialized.");
  }
  
  const deleted = deleteMemory(id);
  if (deleted) {
    const { deleteVector } = await import("../storage/lancedb.js");
    await deleteVector(id);
  }
  return deleted;
}

export async function closeMemoryService(): Promise<void> {
  closeVectorStore();
  closeMetaStore();
  initialized = false;
}
