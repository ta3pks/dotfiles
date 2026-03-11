# Roadmap: Dotfiles Repository — v2.0 Memory System

## Overview

Building a CLI-independent persistent memory system for AI coding assistants. The journey takes us from storage foundation (LanceDB + Ollama) through a functional CLI, AI tool integrations, and finally data management capabilities. Each phase delivers a complete, verifiable capability.

## Milestones

- ✅ **v1.0 MVP** - Phases 1-3 (shipped 2026-03-11)
- 🚧 **v2.0 Memory System** - Phases 4-7 (in progress)

## Phases

<details>
<summary>✅ v1.0 MVP (Phases 1-3) - SHIPPED 2026-03-11</summary>

- [x] Phase 1: Security Audit (4/4 plans) — completed 2026-03-11
- [x] Phase 2: Documentation & Organization (3/3 plans) — completed 2026-03-11
- [x] Phase 3: Bootstrap Automation (3/3 plans) — completed 2026-03-11

**Key accomplishments:**
- Security hardening with Gitleaks integration
- Comprehensive documentation (README + 8 per-tool READMEs)
- Bootstrap automation with manifest tracking, --dry-run, --undo
- 13 automated test cases for bootstrap functionality

</details>

### 🚧 v2.0 Memory System (In Progress)

**Milestone Goal:** CLI-independent persistent memory for AI coding assistants using vector database storage.

- [ ] **Phase 4: Storage Foundation** - LanceDB + SQLite + Ollama embeddings infrastructure
- [ ] **Phase 5: Memory CLI** - Command-line interface for memory operations
- [ ] **Phase 6: AI Integration** - Multi-tool integration (MCP, stdio, HTTP)
- [ ] **Phase 7: Data Management** - Export, backup, and cleanup functionality

## Phase Details

### Phase 4: Storage Foundation
**Goal**: Vector storage and embedding infrastructure is operational
**Depends on**: Nothing (new subsystem)
**Requirements**: VEC-01, VEC-02, VEC-03, EMB-01, EMB-02, EMB-03
**Success Criteria** (what must be TRUE):
  1. LanceDB stores and retrieves vector embeddings
  2. SQLite stores metadata (tags, timestamps, project references)
  3. Ollama generates embeddings locally (no external API calls)
  4. Multiple embedding models work (nomic-embed-text, mxbai-embed-large)
  5. Embeddings are generated automatically when storing content
**Plans**: 2 plans

Plans:
- [ ] 04-01: LanceDB and SQLite setup
- [ ] 04-02: Ollama embedding integration

### Phase 5: Memory CLI
**Goal**: Users can store and retrieve memories via command-line interface
**Depends on**: Phase 4
**Requirements**: CLI-01, CLI-02, CLI-03, CLI-04, CLI-05, MEM-01, MEM-02, MEM-03, MEM-04, MEM-05
**Success Criteria** (what must be TRUE):
  1. User can store code patterns and retrieve them via semantic search
  2. User can store project decisions with context and rationale
  3. User can store conversation context for session continuity
  4. User can search memories semantically by query
  5. User can browse memories by tag, project, or date
  6. User can retrieve a specific memory by its ID
**Plans**: 2 plans

Plans:
- [ ] 05-01: CLI core commands (store, search, retrieve, list)
- [ ] 05-02: Memory type handlers (patterns, decisions, context, preferences)

### Phase 6: AI Integration
**Goal**: Any AI coding tool can access the memory system
**Depends on**: Phase 5
**Requirements**: INT-01, INT-02, INT-03, INT-04
**Success Criteria** (what must be TRUE):
  1. OpenCode can store and search memories via MCP server
  2. Claude Code and Aider can access memories via stdio interface
  3. Cursor can access memories via HTTP API
  4. Memory system works independently of any specific AI tool
**Plans**: 3 plans

Plans:
- [ ] 06-01: MCP server for OpenCode
- [ ] 06-02: Stdio interface for Claude Code/Aider
- [ ] 06-03: HTTP API for Cursor and other tools

### Phase 7: Data Management
**Goal**: Users can manage their memory data (export, backup, cleanup)
**Depends on**: Phase 6
**Requirements**: DATA-01, DATA-02, DATA-03
**Success Criteria** (what must be TRUE):
  1. User can export all memories to a JSON file
  2. User can import memories from a JSON file
  3. User can create and restore backups of the memory database
  4. User can prune old or irrelevant memories to keep database clean
**Plans**: 2 plans

Plans:
- [ ] 07-01: Export/import functionality
- [ ] 07-02: Backup/restore and cleanup commands

## Progress

**Execution Order:**
Phases execute in numeric order: 4 → 5 → 6 → 7

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Security Audit | v1.0 | 4/4 | Complete | 2026-03-11 |
| 2. Documentation & Organization | v1.0 | 3/3 | Complete | 2026-03-11 |
| 3. Bootstrap Automation | v1.0 | 3/3 | Complete | 2026-03-11 |
| 4. Storage Foundation | v2.0 | 0/2 | Not started | - |
| 5. Memory CLI | v2.0 | 0/2 | Not started | - |
| 6. AI Integration | v2.0 | 0/3 | Not started | - |
| 7. Data Management | v2.0 | 0/2 | Not started | - |

---
*Roadmap created: 2026-03-12*
*Last updated: 2026-03-12*
