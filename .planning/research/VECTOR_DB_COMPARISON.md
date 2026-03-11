# Vector Database Comparison for AI Memory System

**Research Date:** 2026-03-12
**Use Case:** CLI-independent persistent memory for AI coding assistants

---

## Reference Implementation: opencode-personal-knowledge

**GitHub:** https://github.com/NocturnLabs/opencode-personal-knowledge

**Architecture:**
- **Vector DB:** LanceDB (embedded)
- **Embeddings:** FastEmbed with BGE-small-en-v1.5 (local, no API keys)
- **Metadata:** SQLite
- **Runtime:** TypeScript/Bun
- **Interface:** MCP server

**Key Features:**
- Semantic search with vector embeddings
- Text search fallback
- Tag organization
- Session memory logging (search across sessions)
- Plug-and-play: no external services required
- Data stored in `~/.local/share/opencode-personal-knowledge/`

**Pros:**
- Already working implementation for OpenCode
- 100% local embeddings (privacy)
- MCP integration ready
- Simple architecture (LanceDB + SQLite + FastEmbed)

**Cons:**
- OpenCode-specific (not CLI-independent)
- Uses FastEmbed, not Ollama

---

## Vector Database Options

### 1. LanceDB ⭐ RECOMMENDED

| Aspect | Details |
|--------|---------|
| **Stars** | 9.4k |
| **License** | Apache 2.0 |
| **Type** | Embedded (no server) |
| **Languages** | Python, Node.js, Rust, REST |
| **Storage** | Lance columnar format |
| **Multimodal** | Yes (text, images, video, point clouds) |

**Pros:**
- ✅ **Embedded** - no server process, just a library
- ✅ **Zero-config** - works out of the box
- ✅ **Fast** - optimized for vector search
- ✅ **Versioning** - automatic data versioning
- ✅ **Proven** - used by opencode-personal-knowledge
- ✅ **Node.js support** - works with TypeScript/Bun

**Cons:**
- ⚠️ Smaller community than Qdrant/Chroma
- ⚠️ Less documentation

---

### 2. Qdrant

| Aspect | Details |
|--------|---------|
| **Stars** | 29.5k |
| **License** | Apache 2.0 |
| **Type** | Server-based |
| **Languages** | Python, JS, Rust, Go, Java, .NET |
| **Storage** | Custom (Rust) |
| **API** | REST + gRPC |

**Pros:**
- ✅ **High performance** - written in Rust
- ✅ **Rich filtering** - payload-based queries
- ✅ **Hybrid search** - sparse + dense vectors
- ✅ **Quantization** - reduces RAM by up to 97%
- ✅ **Distributed** - horizontal scaling support
- ✅ **Large community** - extensive docs

**Cons:**
- ❌ **Requires server** - Docker or binary deployment
- ❌ **More complex** - not embedded
- ❌ **Overkill** for single-user memory

---

### 3. ChromaDB

| Aspect | Details |
|--------|---------|
| **Stars** | 26.6k |
| **License** | Apache 2.0 |
| **Type** | Embedded or Server |
| **Languages** | Python, JavaScript |
| **Storage** | SQLite (embedded) or custom |

**Pros:**
- ✅ **Simple API** - 4 core functions
- ✅ **Can be embedded** - in-memory or persistent
- ✅ **LangChain integration** - popular ecosystem
- ✅ **Auto-embedding** - handles tokenization/embedding

**Cons:**
- ⚠️ **Python-first** - JS support less mature
- ⚠️ **Rust rewrite in progress** - architecture changing
- ⚠️ **Heavier** than LanceDB

---

### 4. sqlite-vec

| Aspect | Details |
|--------|---------|
| **Type** | SQLite extension |
| **Languages** | C, with bindings |
| **Storage** | SQLite |

**Pros:**
- ✅ **Ultra-simple** - just SQLite + extension
- ✅ **Zero dependencies** - minimal footprint
- ✅ **Familiar** - everyone knows SQLite

**Cons:**
- ⚠️ **Limited features** - basic vector search only
- ⚠️ **No advanced indexing** - slower at scale
- ⚠️ **Newer project** - less battle-tested

---

## Comparison Matrix

| Feature | LanceDB | Qdrant | ChromaDB | sqlite-vec |
|---------|---------|--------|----------|------------|
| **Embedded** | ✅ | ❌ | ✅ | ✅ |
| **No server** | ✅ | ❌ | ✅ | ✅ |
| **Node.js** | ✅ | ✅ | ✅ | ⚠️ |
| **Local-first** | ✅ | ✅ | ✅ | ✅ |
| **Ollama support** | ✅ | ✅ | ✅ | ✅ |
| **Setup complexity** | Low | High | Low | Lowest |
| **Performance** | High | Highest | Medium | Medium |
| **Features** | High | Highest | Medium | Low |
| **Community** | Medium | Large | Large | Small |

---

## Recommendation: LanceDB

**Why LanceDB:**

1. **Embedded architecture** - No server process, just a library. Perfect for CLI tools.
2. **Proven pattern** - opencode-personal-knowledge already uses it successfully
3. **Node.js native** - Works with TypeScript/Bun ecosystem
4. **Zero-config** - No setup required, just install and use
5. **Fast enough** - Optimized for vector search workloads
6. **Multimodal ready** - Can store code, text, images if needed later

**Architecture for v2.0:**

```
┌─────────────────────────────────────────┐
│         AI Memory System                 │
├─────────────────────────────────────────┤
│  CLI Interface (works with any AI tool) │
│  - OpenCode, Claude Code, Aider, etc.   │
├─────────────────────────────────────────┤
│  Memory Service                          │
│  - Store/retrieve/search operations     │
├──────────────┬──────────────────────────┤
│  LanceDB     │  SQLite                  │
│  (vectors)   │  (metadata, tags, refs)  │
├──────────────┴──────────────────────────┤
│  Ollama Embeddings (local, private)     │
└─────────────────────────────────────────┘
```

**Alternative:** If you want something even simpler, sqlite-vec is viable for a personal memory system that won't grow huge.

---

## Embeddings: Ollama

**Recommended model:** `nomic-embed-text` or `mxbai-embed-large`

**Why Ollama:**
- ✅ Local (privacy)
- ✅ No API costs
- ✅ Already in your dotfiles setup
- ✅ Multiple model options
- ✅ Fast inference

---

## Next Steps

1. Design memory schema (what to store)
2. Build CLI interface (CLI-independent)
3. Implement LanceDB + Ollama integration
4. Add memory operations (store, search, retrieve)
5. Create adapters for different AI tools
