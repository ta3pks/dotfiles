# Phase 6: AI Integration - Research

**Gathered:** 2026-03-12
**Phase:** 6 - AI Integration
**Requirements:** INT-01, INT-02, INT-03, INT-04

## What Exists

### Current Memory System Architecture

**Storage Layer (Phase 4 complete):**
- `src/storage/sqlite.ts` - Metadata storage with MemoryEntry records
- `src/storage/lancedb.ts` - Vector storage for semantic search
- `src/storage/types.ts` - Type definitions (MemoryEntry, VectorEntry, SearchResult)

**Embedding Layer (Phase 4 complete):**
- `src/embeddings/ollama.ts` - Local embedding generation
- `src/embeddings/models.ts` - Model configurations

**CLI Layer (Phase 5 complete):**
- `src/cli/index.ts` - Commander.js CLI with store, search, get, list, delete commands
- `src/cli/commands/` - Individual command implementations

**Core Types:**
```typescript
interface MemoryEntry {
  id: string;
  content: string;
  tags: string[];
  project: string | null;
  createdAt: number;
  embeddingModel: string;
}

interface SearchResult extends MemoryEntry {
  score: number;
}
```

**Current Dependencies:**
- `@lancedb/lancedb` - Vector database
- `commander` - CLI framework
- `chalk`, `cli-table3`, `ora`, `inquirer` - CLI UX
- `nanoid` - ID generation
- `zod` - Validation

## What's Needed for AI Integration

### 1. MCP Server (INT-01)

**Package:** `@modelcontextprotocol/sdk`

**Server Type:** Stdio transport (no HTTP for MCP itself)

**Tools to expose:**
| Tool | Description | Parameters |
|------|-------------|------------|
| `memory_store` | Store a new memory | content, tags?, project?, type? |
| `memory_search` | Semantic search | query, limit?, project?, tags? |
| `memory_get` | Get by ID | id |
| `memory_list` | List memories | project?, tag?, limit?, offset? |
| `memory_delete` | Delete memory | id |
| `memory_context` | Get context for query | query, max_tokens? |

**Resources to expose:**
- `memory://tags` - List all available tags
- `memory://projects` - List all projects

**Implementation approach:**
```typescript
// src/mcp/server.ts
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

// Reuse existing storage functions
import { initMetaStore, insertMemory, getMemory, listMemories, deleteMemory } from "../storage/sqlite.js";
import { initVectorStore, addVector, searchSimilar, deleteVector } from "../storage/lancedb.js";
import { generateEmbedding } from "../embeddings/ollama.js";
```

### 2. Stdio Interface (INT-02)

**Protocol:** Line-delimited JSON (NDJSON)

**Request format:**
```json
{"command": "store", "content": "...", "tags": ["a", "b"]}
{"command": "search", "query": "...", "limit": 10}
{"command": "get", "id": "abc123"}
{"command": "list", "project": "myproj"}
{"command": "delete", "id": "abc123"}
```

**Response format:**
```json
{"success": true, "data": {...}}
{"success": false, "error": "Not found"}
```

**Exit codes:** 0 = success, 1 = error

**Implementation:**
```typescript
// src/stdio/index.ts
import * as readline from "readline";

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
rl.on("line", async (line) => {
  const request = JSON.parse(line);
  const response = await handleCommand(request);
  console.log(JSON.stringify(response));
});
```

### 3. HTTP API (INT-03)

**Framework options:**
- **Hono** - Lightweight, Bun-native, fast
- **Elysia** - Bun-optimized with end-to-end type safety
- **Express** - Familiar but heavier

**Recommendation:** Hono (lightweight, works well with Bun, minimal overhead)

**Endpoints:**
| Method | Path | Description |
|--------|------|-------------|
| POST | /memories | Store memory |
| GET | /memories | List/search memories |
| GET | /memories/:id | Get specific memory |
| DELETE | /memories/:id | Delete memory |
| GET | /context | Get context for query |
| GET | /tags | List all tags |
| GET | /projects | List all projects |
| GET | /health | Health check |

**Implementation:**
```typescript
// src/http/server.ts
import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();
app.use("/*", cors());

app.post("/memories", async (c) => {
  const body = await c.req.json();
  // reuse storage layer
});

app.get("/memories/search", async (c) => {
  const query = c.req.query("q");
  // reuse search logic
});
```

### 4. Shared Service Layer (INT-04)

**Key insight:** All three interfaces should use the same underlying service, not duplicate logic.

**Proposed architecture:**
```
src/
├── core/
│   └── service.ts     # Unified memory service (NEW)
├── storage/           # Existing storage layer
├── embeddings/        # Existing embedding layer
├── mcp/
│   └── server.ts      # MCP interface
├── stdio/
│   └── index.ts       # Stdio interface
├── http/
│   └── server.ts      # HTTP interface
└── cli/               # Existing CLI (can also use core service)
```

**Core service interface:**
```typescript
// src/core/service.ts
export class MemoryService {
  async store(content: string, options?: StoreOptions): Promise<MemoryEntry>
  async search(query: string, options?: SearchOptions): Promise<SearchResult[]>
  async get(id: string): Promise<MemoryEntry | null>
  async list(options?: ListOptions): Promise<MemoryEntry[]>
  async delete(id: string): Promise<boolean>
  async getContext(query: string, maxTokens?: number): Promise<string>
  async getTags(): Promise<string[]>
  async getProjects(): Promise<string[]>
}
```

## Dependencies to Add

```json
{
  "@modelcontextprotocol/sdk": "^1.0.0",
  "hono": "^4.0.0"
}
```

## Technical Considerations

### MCP Server Specifics
- Uses stdio transport (process.stdin/process.stdout)
- Implements JSON-RPC 2.0 protocol
- Tools are registered with input schemas (JSON Schema)
- Resources are URI-addressable

### Stdio Interface Specifics
- Simpler than MCP - just NDJSON
- Good for shell pipelines and Aider-style tools
- Each line is independent request/response

### HTTP API Specifics
- RESTful design
- CORS enabled for browser access
- Default port: 3456 (configurable via env)
- Health endpoint for monitoring

### Error Handling
All interfaces should return consistent error structure:
```typescript
interface ErrorResponse {
  success: false;
  error: string;
  code?: string; // "NOT_FOUND", "INVALID_INPUT", etc.
}
```

## Validation Architecture

### Dimension 8: Interface Completeness
- MCP server exposes all 6 tools
- Stdio handles all 5 commands
- HTTP implements all 8 endpoints
- All interfaces use shared service

### Dimension 7: Error Handling
- Invalid input returns clear error messages
- Missing resources return 404 (HTTP) / null (MCP)
- Network errors handled gracefully

### Dimension 2: Integration Testing
- Test MCP with Claude Code
- Test stdio with shell pipelines
- Test HTTP with curl/Postman

## Implementation Order

1. **Create core service** - Extract shared logic from CLI into reusable service
2. **MCP server** - Highest priority (OpenCode integration)
3. **Stdio interface** - Simple, good for testing
4. **HTTP API** - For external tools

## Files to Create/Modify

**New files:**
- `memory/src/core/service.ts` - Unified memory service
- `memory/src/mcp/server.ts` - MCP server implementation
- `memory/src/mcp/tools/` - Individual MCP tool handlers
- `memory/src/stdio/index.ts` - Stdio interface
- `memory/src/http/server.ts` - HTTP API server
- `memory/src/http/routes/` - Route handlers

**Modified files:**
- `memory/package.json` - Add new dependencies
- `memory/src/index.ts` - Export new modules

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| MCP SDK API changes | Pin version, add integration tests |
| Concurrent access to SQLite | Use WAL mode (already done) |
| Large vector searches blocking | Add timeout limits |
| HTTP API security | Local-only by default, optional auth later |

---

## RESEARCH COMPLETE

**Summary:** Phase 6 requires creating three interfaces (MCP, stdio, HTTP) that all share a unified memory service. The existing storage and embedding layers are solid foundations. Key work is extracting a service layer and implementing the three interfaces with consistent behavior.

**Next step:** Planning can proceed with clear technical direction.
