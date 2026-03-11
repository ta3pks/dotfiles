import { Database } from "bun:sqlite";
import type { MemoryEntry } from "./types.js";

let db: Database | null = null;

export function initMetaStore(dataPath: string = "./data/metadata.sqlite"): Database {
  db = new Database(dataPath);
  db.run("PRAGMA journal_mode = WAL;");
  
  db.run(`
    CREATE TABLE IF NOT EXISTS memories (
      id TEXT PRIMARY KEY,
      content TEXT NOT NULL,
      tags TEXT DEFAULT '[]',
      project TEXT,
      created_at INTEGER NOT NULL,
      embedding_model TEXT NOT NULL
    )
  `);
  
  db.run(`CREATE INDEX IF NOT EXISTS idx_project ON memories(project)`);
  db.run(`CREATE INDEX IF NOT EXISTS idx_created ON memories(created_at)`);
  db.run(`CREATE INDEX IF NOT EXISTS idx_model ON memories(embedding_model)`);
  
  return db;
}

export function getConnection(): Database {
  if (!db) throw new Error("Meta store not initialized. Call initMetaStore first.");
  return db;
}

export function insertMemory(entry: MemoryEntry): void {
  const stmt = getConnection().query(`
    INSERT INTO memories (id, content, tags, project, created_at, embedding_model)
    VALUES ($id, $content, $tags, $project, $createdAt, $model)
  `);
  
  stmt.run({
    $id: entry.id,
    $content: entry.content,
    $tags: JSON.stringify(entry.tags || []),
    $project: entry.project || null,
    $createdAt: entry.createdAt,
    $model: entry.embeddingModel
  });
}

export function getMemory(id: string): MemoryEntry | null {
  const stmt = getConnection().query(`
    SELECT id, content, tags, project, created_at, embedding_model
    FROM memories WHERE id = $id
  `);
  
  const row = stmt.get({ $id: id }) as any;
  if (!row) return null;
  
  return {
    id: row.id,
    content: row.content,
    tags: JSON.parse(row.tags || "[]"),
    project: row.project,
    createdAt: row.created_at,
    embeddingModel: row.embedding_model
  };
}

export function listMemories(options: {
  project?: string;
  tag?: string;
  limit?: number;
  offset?: number;
} = {}): MemoryEntry[] {
  let sql = "SELECT * FROM memories";
  const conditions: string[] = [];
  const params: Record<string, any> = {};
  
  if (options.project) {
    conditions.push("project = $project");
    params.$project = options.project;
  }
  
  if (options.tag) {
    conditions.push("tags LIKE $tag");
    params.$tag = `%"${options.tag}"%`;
  }
  
  if (conditions.length > 0) {
    sql += " WHERE " + conditions.join(" AND ");
  }
  
  sql += " ORDER BY created_at DESC";
  
  if (options.limit) {
    sql += ` LIMIT ${options.limit}`;
    if (options.offset) {
      sql += ` OFFSET ${options.offset}`;
    }
  }
  
  const stmt = getConnection().query(sql);
  const rows = stmt.all(params) as any[];
  
  return rows.map(row => ({
    id: row.id,
    content: row.content,
    tags: JSON.parse(row.tags || "[]"),
    project: row.project,
    createdAt: row.created_at,
    embeddingModel: row.embedding_model
  }));
}

export function deleteMemory(id: string): boolean {
  const stmt = getConnection().query("DELETE FROM memories WHERE id = $id");
  const result = stmt.run({ $id: id });
  return result.changes > 0;
}

export function closeMetaStore(): void {
  if (db) {
    db.close();
    db = null;
  }
}
