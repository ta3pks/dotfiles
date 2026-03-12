import { nanoid } from "nanoid";
import {
  initMetaStore,
  insertMemory,
  getMemory as getMetaMemory,
  listMemories,
  deleteMemory as deleteMetaMemory,
  getConnection,
} from "../storage/sqlite.js";
import {
  initVectorStore,
  addVector,
  searchSimilar,
  deleteVector,
} from "../storage/lancedb.js";
import { getEmbedding } from "../embeddings/ollama.js";
import type { MemoryEntry, SearchResult } from "../storage/types.js";
import { DEFAULT_MODEL, type ModelName } from "../storage/types.js";
import type { StoreOptions, SearchOptions, ListOptions, ContextOptions } from "./types.js";

export class MemoryService {
  private initialized = false;
  private modelName: ModelName = DEFAULT_MODEL;

  async init(dataPath: string = "./data"): Promise<void> {
    if (this.initialized) return;

    await initVectorStore(`${dataPath}/vectors`, this.modelName);
    initMetaStore(`${dataPath}/metadata.sqlite`);
    this.initialized = true;
  }

  setModel(model: ModelName): void {
    this.modelName = model;
  }

  async store(content: string, options?: StoreOptions): Promise<MemoryEntry> {
    if (!this.initialized) await this.init();

    const id = nanoid();
    const now = Date.now();

    const entry: MemoryEntry = {
      id,
      content,
      tags: options?.tags || [],
      project: options?.project || null,
      createdAt: now,
      embeddingModel: this.modelName,
    };

    const result = await getEmbedding(content, this.modelName);
    const vector = result.embedding;

    await addVector({ id, vector, content });
    insertMemory(entry);

    return entry;
  }

  async search(query: string, options?: SearchOptions): Promise<SearchResult[]> {
    if (!this.initialized) await this.init();

    const queryResult = await getEmbedding(query, this.modelName);
    const queryVector = queryResult.embedding;
    const results = await searchSimilar(queryVector, options?.limit || 10);

    const searchResults: SearchResult[] = [];
    for (const r of results) {
      const meta = getMetaMemory(r.id);
      if (!meta) continue;

      if (options?.project && meta.project !== options.project) continue;
      if (options?.tags && options.tags.length > 0) {
        const hasAllTags = options.tags.every((t) => meta.tags.includes(t));
        if (!hasAllTags) continue;
      }

      searchResults.push({
        ...meta,
        score: r.score,
      });
    }

    return searchResults;
  }

  async get(id: string): Promise<MemoryEntry | null> {
    if (!this.initialized) await this.init();
    return getMetaMemory(id);
  }

  async list(options?: ListOptions): Promise<MemoryEntry[]> {
    if (!this.initialized) await this.init();
    return listMemories({
      project: options?.project,
      tag: options?.tag,
      limit: options?.limit,
      offset: options?.offset,
    });
  }

  async delete(id: string): Promise<boolean> {
    if (!this.initialized) await this.init();

    const meta = getMetaMemory(id);
    if (!meta) return false;

    await deleteVector(id);
    return deleteMetaMemory(id);
  }

  async getContext(query: string, options?: ContextOptions): Promise<string> {
    const results = await this.search(query, {
      limit: 5,
      project: options?.project,
    });

    const maxTokens = options?.maxTokens || 2000;
    let context = "";
    let tokenCount = 0;

    for (const r of results) {
      const entry = `## Memory: ${r.id}\nProject: ${r.project || "none"}\nTags: ${r.tags.join(", ")}\n\n${r.content}\n\n`;
      const tokens = entry.split(/\s+/).length;

      if (tokenCount + tokens > maxTokens) break;

      context += entry;
      tokenCount += tokens;
    }

    return context || "No relevant memories found.";
  }

  async getTags(): Promise<string[]> {
    if (!this.initialized) await this.init();

    const memories = listMemories({ limit: 10000 });
    const tags = new Set<string>();

    for (const m of memories) {
      for (const t of m.tags) {
        tags.add(t);
      }
    }

    return Array.from(tags).sort();
  }

  async getProjects(): Promise<string[]> {
    if (!this.initialized) await this.init();

    const memories = listMemories({ limit: 10000 });
    const projects = new Set<string>();

    for (const m of memories) {
      if (m.project) {
        projects.add(m.project);
      }
    }

    return Array.from(projects).sort();
  }
}

export const memoryService = new MemoryService();
