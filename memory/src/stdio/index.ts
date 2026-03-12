#!/usr/bin/env bun
import * as readline from "readline";
import { MemoryService } from "../core/service.js";
import { z } from "zod";

const StoreSchema = z.object({
  content: z.string().min(1),
  tags: z.array(z.string()).optional(),
  project: z.string().optional(),
});

const SearchSchema = z.object({
  query: z.string().min(1),
  limit: z.number().int().positive().max(100).optional(),
  project: z.string().optional(),
  tags: z.array(z.string()).optional(),
});

const GetSchema = z.object({
  id: z.string().min(1),
});

const ListSchema = z.object({
  project: z.string().optional(),
  tag: z.string().optional(),
  limit: z.number().int().positive().max(1000).optional(),
  offset: z.number().int().nonnegative().optional(),
});

const DeleteSchema = z.object({
  id: z.string().min(1),
});

const ContextSchema = z.object({
  query: z.string().min(1),
  maxTokens: z.number().int().positive().optional(),
  project: z.string().optional(),
});

const handlers: Record<string, (data: any) => Promise<any>> = {
  store: async (data: z.infer<StoreCommand>) => {
    const service = new MemoryService();
    await service.init();
    return service.store(data.content, {
      tags: data.tags,
      project: data.project,
    });
  },
  search: async (data: z.infer<SearchCommand>) => {
    const service = new MemoryService();
    await service.init();
    return service.search(data.query, {
      limit: data.limit,
      project: data.project,
      tags: data.tags,
    });
  },
  get: async (data: z.infer<GetCommand>) => {
    const service = new MemoryService();
    await service.init();
    return service.get(data.id);
  },
  list: async (data: z.infer<ListCommand>) => {
    const service = new MemoryService();
    await service.init();
    return service.list({
      project: data.project,
      tag: data.tag,
      limit: data.limit,
      offset: data.offset,
    });
  },
  delete: async (data: z.infer<DeleteCommand>) => {
    const service = new MemoryService();
    await service.init();
    return service.delete(data.id);
  },
  context: async (data: z.infer<ContextCommand>) => {
    const service = new MemoryService();
    await service.init();
    return service.getContext(data.query, {
      maxTokens: data.maxTokens,
      project: data.project,
    });
  },
};

const schemas: Record<string, z.ZodTypeAny> = {
  store: StoreSchema,
  search: SearchSchema,
  get: GetSchema,
  list: ListSchema,
  delete: DeleteSchema,
  context: ContextSchema,
};

async function handleRequest(request: unknown): Promise<StdioResponse> {
  try {
    const parsed = typeof request === "string" ? JSON.parse(request) : request;
    const command = parsed.command;

    if (!handlers[command]) {
      return { success: false, error: `Unknown command: ${command}`, code: "UNKNOWN_COMMAND" };
    }

    const schema = schemas[command];
    const validated = schema.parse(parsed);

    const result = await handlers[command](validated);
    return { success: true, data: result };
  } catch (err) {
    if (err instanceof z.ZodError) {
      return { success: false, error: err.message, code: "VALIDATION_ERROR" };
    }
    return { success: false, error: err.message, code: "INTERNAL_ERROR" };
  }
}

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false,
});

rl.on("line", async (line) => {
  const response = await handleRequest(line);
  console.log(JSON.stringify(response));
});

