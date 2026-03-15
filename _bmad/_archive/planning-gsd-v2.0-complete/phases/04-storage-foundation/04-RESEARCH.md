# Phase 4: Storage Foundation - Research

**Researched:** 2026-03-12
**Domain:** Vector database storage and embedding infrastructure
**Confidence:** HIGH

## Summary

Phase 4 establishes the foundational storage layer for the AI memory system using a dual-database architecture: LanceDB for vector embeddings and SQLite for metadata. Ollama provides local embedding generation with no external API dependencies.

**Primary recommendation:** Use LanceDB Node.js SDK (v0.26.2) with Bun's built-in SQLite driver and Ollama's `/api/embed` endpoint. This combination is proven (opencode-personal-knowledge reference), zero-config, and fully local.

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| VEC-01 | LanceDB integration for vector storage | Standard Stack: @lancedb/lancedb v0.26.2 with embedded mode |
| VEC-02 | SQLite for metadata (tags, timestamps, project refs) | Standard Stack: bun:sqlite built-in driver |
| VEC-03 | Automatic embedding generation on store | Architecture Pattern: EmbeddingService with hooks |
| EMB-01 | Ollama integration for local embeddings | Standard Stack: HTTP client to localhost:11434/api/embed |
| EMB-02 | Support for multiple embedding models (nomic, mxbai) | Available models: nomic-embed-text, mxbai-embed-large, embeddinggemma |
| EMB-03 | No external API calls (privacy) | Ollama runs locally, verified via curl test |

</phase_requirements>

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| @lancedb/lancedb | 0.26.2 | Vector database | Embedded, zero-config, Node.js native, proven pattern |
| bun:sqlite | Built-in | Metadata storage | Fastest SQLite driver for JS, no dependencies |
| Ollama | Local | Embedding generation | Privacy-first, no API keys, already in dotfiles |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| TypeScript | 5.x | Type safety | All code |
| Zod | 3.x | Runtime validation | API input/output schemas |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| LanceDB | Qdrant | Requires server process, overkill for single-user |
| LanceDB | ChromaDB | Python-first, JS support less mature |
| bun:sqlite | better-sqlite3 | 3-6x slower, external dependency |
| Ollama | OpenAI embeddings | External API, privacy concern, costs |

**Installation:**
```bash
bun add @lancedb/lancedb zod
# bun:sqlite is built-in, no install needed
# Ollama already running via systemd user service
```

## Architecture Patterns

### Recommended Project Structure

```
src/
├── storage/
│   ├── index.ts              # Storage service exports
│   ├── lancedb.ts            # LanceDB connection and table management
│   ├── sqlite.ts             # SQLite connection and schema
│   └── types.ts              # Storage-related types
├── embeddings/
│   ├── index.ts              # Embedding service exports
│   ├── ollama.ts             # Ollama API client
│   └── models.ts             # Model configurations
├── memory/
│   ├── index.ts              # Memory service (store, search, retrieve)
│   └── types.ts              # Memory entry types
└── tests/
    ├── storage.test.ts       # Storage layer tests
    └── embeddings.test.ts    # Embedding tests
```

### Pattern 1: Dual-Database Architecture

**What:** LanceDB stores vectors, SQLite stores metadata. Linked by memory ID.

**When to use:** Always - this is the core storage pattern.

**Example:**
```typescript
import * as lancedb from "@lancedb/lancedb";
import { Database } from "bun:sqlite";

const vectorDb = await lancedb.connect("./data/vectors");
const metaDb = new Database("./data/metadata.sqlite");

metaDb.run(`
  CREATE TABLE IF NOT EXISTS memories (
    id TEXT PRIMARY KEY,
    content TEXT NOT NULL,
    tags TEXT,
    project TEXT,
    created_at INTEGER,
    embedding_model TEXT
  )
`);

metaDb.run("PRAGMA journal_mode = WAL;");
```

**Source:** VECTOR_DB_COMPARISON.md architecture diagram

### Pattern 2: LanceDB Table Operations

**What:** Create, insert, and search vector data.

**Example:**
```typescript
import * as lancedb from "@lancedb/lancedb";

const db = await lancedb.connect("./data/vectors");

const table = await db.createTable("memories", [
  { id: "mem-001", vector: [0.1, 0.2, ...], content: "sample" }
], { mode: "overwrite" });

const results = await table
  .vectorSearch(queryVector)
  .limit(10)
  .toArray();
```

**Source:** npmjs.com/@lancedb/lancedb, LanceDB docs

### Pattern 3: Ollama Embedding API

**What:** Generate embeddings via HTTP POST to local Ollama.

**Example:**
```typescript
interface EmbedRequest {
  model: string;
  input: string | string[];
  truncate?: boolean;
}

interface EmbedResponse {
  model: string;
  embeddings: number[][];
  total_duration: number;
  prompt_eval_count: number;
}

async function embed(text: string, model = "nomic-embed-text"): Promise<number[]> {
  const response = await fetch("http://localhost:11434/api/embed", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model, input: text })
  });
  
  const data: EmbedResponse = await response.json();
  return data.embeddings[0];
}

const vector = await embed("Hello world");
```

**Source:** docs.ollama.com/api/embed, verified via curl test

### Pattern 4: Automatic Embedding on Store

**What:** Generate embeddings automatically when storing content.

**Example:**
```typescript
interface MemoryEntry {
  id: string;
  content: string;
  tags?: string[];
  project?: string;
}

async function storeMemory(entry: MemoryEntry): Promise<void> {
  const vector = await embed(entry.content);
  
  metaDb.transaction(() => {
    metaDb.run(`
      INSERT INTO memories (id, content, tags, project, created_at, embedding_model)
      VALUES ($id, $content, $tags, $project, $createdAt, $model)
    `, {
      $id: entry.id,
      $content: entry.content,
      $tags: JSON.stringify(entry.tags || []),
      $project: entry.project || null,
      $createdAt: Date.now(),
      $model: "nomic-embed-text"
    });
    
    await vectorTable.add([{
      id: entry.id,
      vector: vector,
      content: entry.content
    }]);
  })();
}
```

### Pattern 5: Multi-Model Support

**What:** Support different embedding models with different dimensions.

**Example:**
```typescript
const EMBEDDING_MODELS = {
  "nomic-embed-text": { dimensions: 768, family: "nomic-bert" },
  "mxbai-embed-large": { dimensions: 1024, family: "bert" },
  "embeddinggemma": { dimensions: 768, family: "gemma3" }
} as const;

type ModelName = keyof typeof EMBEDDING_MODELS;

async function embedWithModel(text: string, model: ModelName) {
  const config = EMBEDDING_MODELS[model];
  const vector = await embed(text, model);
  return { vector, dimensions: config.dimensions, model };
}
```

### Anti-Patterns to Avoid

- **Storing vectors in SQLite BLOBs:** Use LanceDB for vectors, SQLite only for metadata
- **Single table for everything:** LanceDB for vectors, SQLite for metadata - keep concerns separate
- **Synchronous Ollama calls in hot paths:** Embedding generation is ~18ms, use async/await
- **Hardcoded model dimensions:** Different models have different dimensions (768, 1024)

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Vector similarity search | Custom cosine similarity | LanceDB `.vectorSearch()` | Optimized, indexed, fast |
| Embedding generation | Custom model loading | Ollama `/api/embed` | Already running, battle-tested |
| SQLite connection | Raw SQL driver | `bun:sqlite` | 3-6x faster, built-in |
| Schema migrations | Custom SQL runner | Direct `.run()` with IF NOT EXISTS | Simple schema, no ORM needed |

**Key insight:** LanceDB handles vector indexing and search optimization. Ollama handles model loading and inference. Bun handles SQLite efficiently. Build only the orchestration layer.

## Common Pitfalls

### Pitfall 1: Vector Dimension Mismatch

**What goes wrong:** Storing vectors with wrong dimensions causes search failures.

**Why it happens:** Different models produce different vector sizes (nomic: 768, mxbai: 1024).

**How to avoid:** 
1. Store embedding model name with each memory
2. Create separate LanceDB tables per model
3. Validate dimensions before insert

**Warning signs:** `TypeError` on vector search, empty results

### Pitfall 2: Missing WAL Mode for SQLite

**What goes wrong:** Concurrent reads/writes cause database locks.

**Why it happens:** SQLite default journal mode doesn't support concurrent access well.

**How to avoid:** Always enable WAL mode on connection:
```typescript
const db = new Database("./data/metadata.sqlite");
db.run("PRAGMA journal_mode = WAL;");
```

**Warning signs:** `SQLITE_BUSY` errors, slow writes

### Pitfall 3: Ollama Not Running

**What goes wrong:** Embedding generation fails silently or times out.

**Why it happens:** Ollama service not started or crashed.

**How to avoid:** 
1. Check health before embedding: `GET http://localhost:11434/api/tags`
2. Add retry logic with exponential backoff
3. Verify systemd service is active

**Warning signs:** `ECONNREFUSED` on localhost:11434

### Pitfall 4: LanceDB Table Overwrite

**What goes wrong:** Using `mode: "overwrite"` accidentally deletes all data.

**Why it happens:** LanceDB createTable modes are destructive by default.

**How to avoid:**
```typescript
const table = await db.createTable("memories", data, { 
  mode: "exist_ok"  // Don't error if exists
});
// Or: db.openTable("memories") for existing table
```

**Warning signs:** Missing data after restart

### Pitfall 5: Large Content Truncation

**What goes wrong:** Long content exceeds embedding model context window.

**Why it happens:** Embedding models have token limits (~8192 for nomic).

**How to avoid:**
1. Use `truncate: true` in Ollama request (default)
2. Log when truncation occurs via `prompt_eval_count`
3. Consider chunking for very long content

**Warning signs:** Shorter `prompt_eval_count` than expected

## Code Examples

### LanceDB Connection and Table Management

```typescript
import * as lancedb from "@lancedb/lancedb";

export async function initVectorStore(path: string) {
  const db = await lancedb.connect(path);
  
  const table = await db.createTable("memories", [
    { id: "init", vector: new Array(768).fill(0), content: "" }
  ], { mode: "exist_ok" });
  
  return { db, table };
}

export async function searchSimilar(table: any, vector: number[], limit = 10) {
  return table
    .vectorSearch(vector)
    .limit(limit)
    .toArray();
}
```

### SQLite Metadata Store

```typescript
import { Database } from "bun:sqlite";

export function initMetaStore(path: string) {
  const db = new Database(path);
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
  
  return db;
}

export function insertMemory(db: Database, entry: MemoryEntry) {
  const stmt = db.query(`
    INSERT INTO memories (id, content, tags, project, created_at, embedding_model)
    VALUES ($id, $content, $tags, $project, $createdAt, $model)
  `);
  
  return stmt.run({
    $id: entry.id,
    $content: entry.content,
    $tags: JSON.stringify(entry.tags || []),
    $project: entry.project || null,
    $createdAt: Date.now(),
    $model: entry.model
  });
}
```

### Ollama Embedding Client

```typescript
const OLLAMA_URL = "http://localhost:11434";

export async function getEmbedding(
  text: string, 
  model: string = "nomic-embed-text"
): Promise<{ embedding: number[]; tokenCount: number }> {
  const response = await fetch(`${OLLAMA_URL}/api/embed`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model, input: text, truncate: true })
  });
  
  if (!response.ok) {
    throw new Error(`Ollama error: ${response.status}`);
  }
  
  const data = await response.json();
  return {
    embedding: data.embeddings[0],
    tokenCount: data.prompt_eval_count
  };
}

export async function checkOllamaHealth(): Promise<boolean> {
  try {
    const response = await fetch(`${OLLAMA_URL}/api/tags`, { 
      method: "GET",
      signal: AbortSignal.timeout(2000)
    });
    return response.ok;
  } catch {
    return false;
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| FastEmbed (Python) | Ollama local API | Project decision | Simpler, already in dotfiles |
| Pinecone cloud | LanceDB embedded | 2024 | Zero-config, privacy-first |
| ORM for SQLite | Direct bun:sqlite | Bun native | 3-6x faster, less complexity |

**Deprecated/outdated:**
- ChromaDB Python SDK: JavaScript support immature
- Qdrant for personal use: Requires server, overkill

## Open Questions

1. **Should we create separate LanceDB tables per embedding model?**
   - What we know: Different models have different dimensions (768 vs 1024)
   - What's unclear: Can LanceDB handle mixed dimensions in one table?
   - Recommendation: Yes, create separate tables per model (e.g., `memories_nomic`, `memories_mxbai`)

2. **What's the optimal batch size for Ollama embedding?**
   - What we know: Ollama supports batch input via `input: string[]`
   - What's unclear: Performance characteristics at scale
   - Recommendation: Start with single-item inserts, add batch optimization in Phase 5

3. **Should we use UUID or nanoid for memory IDs?**
   - What we know: Both work, nanoid is shorter
   - What's unclear: Project preference
   - Recommendation: Use nanoid (already in ecosystem, shorter IDs)

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Bun Test (built-in) |
| Config file | None - bunfig.toml optional |
| Quick run command | `bun test` |
| Full suite command | `bun test --coverage` |
| Estimated runtime | ~5 seconds |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| VEC-01 | LanceDB stores and retrieves vectors | unit | `bun test tests/storage/lancedb.test.ts` | ❌ Wave 0 gap |
| VEC-02 | SQLite stores metadata correctly | unit | `bun test tests/storage/sqlite.test.ts` | ❌ Wave 0 gap |
| VEC-03 | Embeddings auto-generated on store | integration | `bun test tests/memory/store.test.ts` | ❌ Wave 0 gap |
| EMB-01 | Ollama generates embeddings locally | unit | `bun test tests/embeddings/ollama.test.ts` | ❌ Wave 0 gap |
| EMB-02 | Multiple embedding models work | unit | `bun test tests/embeddings/models.test.ts` | ❌ Wave 0 gap |
| EMB-03 | No external API calls made | integration | `bun test tests/embeddings/privacy.test.ts` | ❌ Wave 0 gap |

### Nyquist Sampling Rate

- **Minimum sample interval:** After every committed task → run: `bun test`
- **Full suite trigger:** Before merging final task of any plan wave
- **Phase-complete gate:** Full suite green before `/gsd-verify-work` runs
- **Estimated feedback latency per task:** ~5 seconds

### Wave 0 Gaps (must be created before implementation)

- [ ] `tests/storage/lancedb.test.ts` — covers VEC-01
- [ ] `tests/storage/sqlite.test.ts` — covers VEC-02
- [ ] `tests/memory/store.test.ts` — covers VEC-03
- [ ] `tests/embeddings/ollama.test.ts` — covers EMB-01
- [ ] `tests/embeddings/models.test.ts` — covers EMB-02
- [ ] `tests/embeddings/privacy.test.ts` — covers EMB-03
- [ ] `tests/fixtures/memory.ts` — shared test fixtures
- [ ] Framework: Bun built-in (no install needed)

## Sources

### Primary (HIGH confidence)

- npmjs.com/@lancedb/lancedb - Package details and basic usage
- docs.ollama.com/api/embed - Embedding API specification
- bun.sh/docs/api/sqlite - SQLite driver documentation
- bun.sh/docs/test/writing - Test framework documentation
- .planning/research/VECTOR_DB_COMPARISON.md - Architecture decision context

### Secondary (MEDIUM confidence)

- lancedb.github.io documentation - Vector search patterns
- GitHub ollama/ollama docs - API examples
- Verified Ollama API via curl: `curl http://localhost:11434/api/embed -d '{"model":"nomic-embed-text","input":"hello"}'`

### Tertiary (LOW confidence)

- None - all core claims verified with primary sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All packages verified with official docs, Ollama tested locally
- Architecture: HIGH - Reference implementation (opencode-personal-knowledge) proves pattern
- Pitfalls: HIGH - Based on official documentation and common patterns

**Research date:** 2026-03-12
**Valid until:** 2026-04-12 (30 days - stable libraries, local Ollama)
