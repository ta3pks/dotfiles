import * as lancedb from "@lancedb/lancedb";
import type { VectorEntry, SearchResult, MemoryEntry } from "./types.js";
import { EMBEDDING_MODELS, DEFAULT_MODEL, type ModelName } from "./types.js";

let db: lancedb.Connection | null = null;
let currentTable: string | null = null;

export async function initVectorStore(
  dataPath: string = "./data/vectors",
  modelName: ModelName = DEFAULT_MODEL
): Promise<lancedb.Connection> {
  db = await lancedb.connect(dataPath);
  currentTable = `memories_${modelName.replace(/-/g, "_")}`;
  
  const dimensions = EMBEDDING_MODELS[modelName].dimensions;
  const initialData: VectorEntry[] = [{
    id: "init",
    vector: new Array(dimensions).fill(0),
    content: ""
  }];
  
  await db.createTable(currentTable, initialData, { mode: "exist_ok" });
  return db;
}

export function getConnection(): lancedb.Connection {
  if (!db) throw new Error("Vector store not initialized. Call initVectorStore first.");
  return db;
}

export function getTableName(): string {
  if (!currentTable) throw new Error("No table selected. Call initVectorStore first.");
  return currentTable;
}

export async function addVector(entry: VectorEntry): Promise<void> {
  const conn = getConnection();
  const table = await conn.openTable(getTableName());
  await table.add([entry]);
}

export async function searchSimilar(
  queryVector: number[],
  limit: number = 10
): Promise<Array<{ id: string; content: string; score: number }>> {
  const conn = getConnection();
  const table = await conn.openTable(getTableName());
  
  const results = await table
    .vectorSearch(queryVector)
    .limit(limit)
    .toArray();
  
  return results.map((r: any) => ({
    id: r.id,
    content: r.content,
    score: r._distance ?? 0
  }));
}

export async function deleteVector(id: string): Promise<void> {
  const conn = getConnection();
  const table = await conn.openTable(getTableName());
  await table.delete(`id = '${id}'`);
}

export async function closeVectorStore(): Promise<void> {
  db = null;
  currentTable = null;
}
