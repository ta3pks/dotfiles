# Phase 6: AI Integration - Context

**Gathered:** 2026-03-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Expose memory system to AI coding assistants via multiple interfaces. AI tools can store and retrieve memories programmatically. Success criteria from roadmap:

1. User can call memory tools from Claude Code via MCP server
2. User can call memory tools via stdio (piped input/output)
3. User can call memory tools via HTTP API
4. User can list available tools and their capabilities
5. User can get memory context for a specific query

</domain>

<decisions>
## Implementation Decisions

### Interface Priority
- **Primary interface: MCP server** — Most AI coding tools use MCP protocol
- Secondary: stdio for simple shell integration
- Tertiary: HTTP API for remote/external tool access
- All three interfaces expose the same core functionality

### MCP Server Design
- Use `@modelcontextprotocol/sdk` TypeScript package
- Tools exposed:
  - `memory_store` — Store a new memory
  - `memory_search` — Semantic search for memories
  - `memory_get` — Retrieve specific memory by ID
  - `memory_list` — List memories with filters
  - `memory_delete` — Delete a memory
  - `memory_context` — Get relevant context for a query (for AI assistants)
- Resources exposed:
  - `memory://tags` — List all available tags
  - `memory://projects` — List all projects
- Server runs as stdio process (no HTTP required for MCP)

### Stdio Interface
- Line-delimited JSON for structured communication
- Commands: `store`, `search`, `get`, `list`, `delete`, `context`
- Input: JSON object per line, Output: JSON response per line
- Exit code 0 for success, non-zero for errors
- Useful for shell scripts and simple integrations

### HTTP API
- RESTful design with JSON bodies
- Endpoints:
  - `POST /memories` — Store memory
  - `GET /memories` — List/search memories
  - `GET /memories/:id` — Get specific memory
  - `DELETE /memories/:id` — Delete memory
  - `GET /context` — Get context for query
  - `GET /tags` — List tags
  - `GET /projects` — List projects
- Port configurable via environment variable (default: 3456)
- CORS enabled for browser access

### Claude's Discretion
- Exact MCP tool schemas and descriptions
- Error response formats for each interface
- Authentication mechanism for HTTP API (if any)
- Rate limiting strategy
- Logging and debugging output format

</decisions>

<specifics>
## Specific Ideas

- MCP server should feel native to Claude Code and similar tools
- stdio interface should work well in shell pipelines
- HTTP API should be simple and RESTful — no complex auth needed for local use
- All interfaces should share the same underlying memory service

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 06-ai-integration*
*Context gathered: 2026-03-12*
