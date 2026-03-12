import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { MemoryService } from "../core/service.js";
import type { MemoryEntry } from "../storage/types.js";

const server = new McpServer(
  {
    name: "memory",
    version: "1.0.0",
  },
  {
    name: "memory_store",
    description: "Store a new memory",
    inputSchema: {
      type: "object",
      properties: {
        content: { type: "string", description: "Memory content to store" },
        tags: {
          type: "array",
          items: { type: "string" },
          description: "Optional tags for categorization"
        },
        project: { type: "string", description: "Optional project reference" },
      },
      required: ["content"]
    }
  },
  async (args) => {
    const service = new MemoryService();
    await service.init();
    const entry = await service.store(args.content, {
      tags: args.tags,
      project: args.project,
    });
    return { content: [entry] };
  }
);

server.tool(
  "memory_search",
  "Semantic search for memories",
  {
    query: { type: "string", description: "Search query" },
    limit: { type: "number", description: "Max results (default 10)" },
    project: { type: "string", description: "Filter by project" },
    tags: {
      type: "array",
      items: { type: "string" },
      description: "Filter by tags"
    },
  },
  async (args) => {
    const service = new MemoryService();
    await service.init();
    const results = await service.search(args.query, {
      limit: args.limit,
      project: args.project,
      tags: args.tags,
    });
    return { content: { results } };
  }
);

server.tool(
  "memory_get",
  "Get a specific memory by ID",
  { id: { type: "string", description: "Memory ID" } },
  async (args) => {
    const service = new MemoryService();
    await service.init();
    const entry = await service.get(args.id);
    if (!entry) {
      return { content: [{ type: "text", text: `Memory ${args.id} not found` }] };
    }
    return { content: [entry] };
  }
);

server.tool(
  "memory_list",
  "List memories with optional filters",
  {
    project: { type: "string", description: "Filter by project" },
    tag: { type: "string", description: "Filter by tag" },
    limit: { type: "number", description: "Max results" },
    offset: { type: "number", description: "Offset for pagination" },
  },
  async (args) => {
    const service = new MemoryService();
    await service.init();
    const results = await service.list({
      project: args.project,
      tag: args.tag,
      limit: args.limit,
      offset: args.offset,
    });
    return { content: { memories: results } };
  }
);

server.tool(
  "memory_delete",
  "Delete a memory",
  { id: { type: "string", description: "Memory ID to delete" } },
  async (args) => {
    const service = new MemoryService();
    await service.init();
    const success = await service.delete(args.id);
    return { content: [{ success }] };
  }
);

server.tool(
  "memory_context",
  "Get relevant context for a query",
  {
    query: { type: "string", description: "Query to get context for" },
    maxTokens: { type: "number", description: "Max tokens in response (default 2000)" },
    project: { type: "string", description: "Filter by project" },
  },
  async (args) => {
    const service = new MemoryService();
    await service.init();
    const context = await service.getContext(args.query, {
      maxTokens: args.maxTokens,
      project: args.project,
    });
    return { content: [{ context }] };
  }
);

server.resource(
  "memory://tags",
  "List all available tags",
  async () => {
    const service = new MemoryService();
    await service.init();
    const tags = await service.getTags();
    return { contents: JSON.stringify(tags, null, 2) };
  }
);

server.resource(
  "memory://projects",
  "List all projects",
  async () => {
    const service = new MemoryService();
    await service.init();
    const projects = await service.getProjects();
    return { contents: JSON.stringify(projects, null, 2) };
  }
);

export async function runMcpServer(): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Memory MCP server running on stdio");
}
