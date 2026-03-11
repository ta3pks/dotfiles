# Requirements: Dotfiles Repository — v2.0 Memory System

**Defined:** 2026-03-12
**Core Value:** CLI-independent persistent memory for AI coding assistants

## v2 Requirements

### Core Storage

- [ ] **MEM-01**: System stores code patterns and solutions with semantic search
- [ ] **MEM-02**: System stores project decisions with context and rationale
- [ ] **MEM-03**: System stores conversation context for session continuity
- [ ] **MEM-04**: System stores cross-project knowledge (reusable patterns)
- [ ] **MEM-05**: System stores user preferences and coding style

### Vector Database

- [ ] **VEC-01**: LanceDB integration for vector storage
- [ ] **VEC-02**: SQLite for metadata (tags, timestamps, project refs)
- [ ] **VEC-03**: Automatic embedding generation on store

### Embeddings

- [ ] **EMB-01**: Ollama integration for local embeddings
- [ ] **EMB-02**: Support for multiple embedding models (nomic, mxbai)
- [ ] **EMB-03**: No external API calls (privacy)

### CLI Interface

- [ ] **CLI-01**: Command-line tool for memory operations
- [ ] **CLI-02**: Store command (add memory with auto-embedding)
- [ ] **CLI-03**: Search command (semantic search across memories)
- [ ] **CLI-04**: Retrieve command (get memory by ID)
- [ ] **CLI-05**: List command (browse by tag/project/date)

### AI Tool Integration

- [ ] **INT-01**: MCP server for OpenCode integration
- [ ] **INT-02**: Stdio interface for Claude Code/Aider
- [ ] **INT-03**: HTTP API for Cursor/other tools
- [ ] **INT-04**: Works with any AI tool (CLI-independent)

### Data Management

- [ ] **DATA-01**: Export/import memories (JSON format)
- [ ] **DATA-02**: Backup/restore functionality
- [ ] **DATA-03**: Memory cleanup (prune old/irrelevant)

## v3 Requirements

Deferred to future release.

### Advanced Features

- **ADV-01**: Memory graph (link related memories)
- **ADV-02**: Memory summarization (condense old sessions)
- **ADV-03**: Memory sharing (export subset for team)
- **ADV-04**: Memory sync (optional cloud backup)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Cloud-only storage | Privacy requires local-first |
| Real-time collaboration | Single-user focus |
| GUI interface | CLI-first design |
| Cloud embedding APIs | Privacy, no external API calls |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| MEM-01 | TBD | Pending |
| MEM-02 | TBD | Pending |
| MEM-03 | TBD | Pending |
| MEM-04 | TBD | Pending |
| MEM-05 | TBD | Pending |
| VEC-01 | TBD | Pending |
| VEC-02 | TBD | Pending |
| VEC-03 | TBD | Pending |
| EMB-01 | TBD | Pending |
| EMB-02 | TBD | Pending |
| EMB-03 | TBD | Pending |
| CLI-01 | TBD | Pending |
| CLI-02 | TBD | Pending |
| CLI-03 | TBD | Pending |
| CLI-04 | TBD | Pending |
| CLI-05 | TBD | Pending |
| INT-01 | TBD | Pending |
| INT-02 | TBD | Pending |
| INT-03 | TBD | Pending |
| INT-04 | TBD | Pending |
| DATA-01 | TBD | Pending |
| DATA-02 | TBD | Pending |
| DATA-03 | TBD | Pending |

**Coverage:**
- v2 requirements: 22 total
- Mapped to phases: 0
- Unmapped: 22 ⚠️

---
*Requirements defined: 2026-03-12*
*Last updated: 2026-03-12 after v2.0 requirements definition*
