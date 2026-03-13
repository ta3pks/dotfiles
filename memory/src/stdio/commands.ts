#!/usr/bin/env bun
import { MemoryService } from "../core/service.js";
import type {
  StdioRequest,
  StdioResponse,
  StoreCommand,
  SearchCommand,
  GetCommand,
  ListCommand,
  DeleteCommand,
  ContextCommand,
} from "./types.js";
import {
  StoreSchema,
  SearchSchema,
  GetSchema,
  ListSchema,
  DeleteSchema,
  ContextSchema,
} from "./types.js";

/**
 * Handle a store command
 */
export async function handleStore(
  service: MemoryService,
  request: StoreCommand
): Promise<StdioResponse> {
  const parsed = StoreSchema.safeParse(request);
  if (!parsed.success) {
    return {
      success: false,
      error: parsed.error.message,
      code: "VALIDATION_ERROR",
    };
  }

  const entry = await service.store(request.content, {
    tags: request.tags,
    project: request.project,
  });

  return {
    success: true,
    data: { id: entry.id },
  };
}

/**
 * Handle search command
 */
export async function handleSearch(
  service: MemoryService,
  request: SearchCommand
): Promise<StdioResponse> {
  const parsed = SearchSchema.safeParse(request);
  if (!parsed.success) {
    return {
      success: false,
      error: parsed.error.message,
      code: "VALIDATION_ERROR",
    };
  }

  const results = await service.search(request.query, {
    limit: request.limit,
    project: request.project,
    tags: request.tags,
  });

  return {
    success: true,
    data: results,
  };
}

/**
 * Handle get command
 */
export async function handleGet(
  service: MemoryService,
  request: GetCommand
): Promise<StdioResponse> {
  const parsed = GetSchema.safeParse(request);
  if (!parsed.success) {
    return {
      success: false,
      error: parsed.error.message,
      code: "VALIDATION_ERROR",
    };
  }

  const memory = await service.get(request.id);
  if (!memory) {
    return {
      success: false,
      error: "Memory not found",
      code: "NOT_FOUND",
    };
  }

  return {
    success: true,
    data: memory,
  };
}

/**
 * Handle list command
 */
export async function handleList(
  service: MemoryService,
  request: ListCommand
): Promise<StdioResponse> {
  const parsed = ListSchema.safeParse(request);
  if (!parsed.success) {
    return {
      success: false,
      error: parsed.error.message,
      code: "VALIDATION_ERROR",
    };
  }

  const results = await service.list({
    project: request.project,
    tag: request.tag,
    limit: request.limit,
    offset: request.offset,
  });

  return {
    success: true,
    data: results,
  };
}

/**
 * Handle delete command
 */
export async function handleDelete(
  service: MemoryService,
  request: DeleteCommand
): Promise<StdioResponse> {
  const parsed = DeleteSchema.safeParse(request);
  if (!parsed.success) {
    return {
      success: false,
      error: parsed.error.message,
      code: "VALIDATION_ERROR",
    };
  }

  const deleted = await service.delete(request.id);
  if (!deleted) {
    return {
      success: false,
      error: "Memory not found",
      code: "NOT_FOUND",
    };
  }

  return {
    success: true,
    data: { deleted: true },
  };
}

/**
 * Handle context command
 */
export async function handleContext(
  service: MemoryService,
  request: ContextCommand
): Promise<StdioResponse> {
  const parsed = ContextSchema.safeParse(request);
  if (!parsed.success) {
    return {
      success: false,
      error: parsed.error.message,
      code: "VALIDATION_ERROR",
    };
  }

  const context = await service.getContext(request.query, {
    maxTokens: request.maxTokens,
    project: request.project,
  });

  return {
    success: true,
    data: context,
  };
}

/**
 * Main command router
 */
export async function handleCommand(
  service: MemoryService,
  request: StdioRequest
): Promise<StdioResponse> {
  const handlers: Record<string, (s: MemoryService, r: any) => Promise<StdioResponse>> = {
    store: handleStore,
    search: handleSearch,
    get: handleGet,
    list: handleList,
    delete: handleDelete,
    context: handleContext,
  };

  const handler = handlers[request.command];

  if (!handler) {
    return {
      success: false,
      error: `Unknown command: ${request.command}`,
      code: "UNKNOWN_COMMAND",
    };
  }

  return handler(service, request);
}
