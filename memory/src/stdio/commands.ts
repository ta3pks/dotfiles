#!/usr/bin/env bun
import { MemoryService } from "../core/service.js";
import type {
  StdioRequest,
  StdioResponse,
  StoreRequest
  SearchRequest
  GetRequest
  ListRequest
  DeleteRequest
  ContextRequest
} from "./types.js";
import { handleCommand } from "./commands.js";

import {
  z,
} from "zod";

import {
  StoreSchema,
  SearchSchema,
  GetSchema,
  ListSchema,
  DeleteSchema,
  ContextSchema,
} from "./types.js";

import { z } from "zod";
import {
  StoreSchema,
  SearchSchema,
  GetSchema,
  ListSchema,
  DeleteSchema,
  ContextSchema,
} from "./types.js";

import { StdioResponse } from "./types.js";

/**
 * Handle a store command
 */
export async function handleStore(
  service: MemoryService,
  request: StoreRequest
): Promise<StdioResponse> {
    // Validate request
    const parsed = StoreSchema.safeParse(request);
    if (!parsed.success) {
        return {
            success: false,
            error: "Invalid store request",
            code: "VALIDATION_ERROR",
        };
    }

    // Store memory
    const id = await service.store(request.content, {
        tags: request.tags,
        project: request.project,
    });

    return {
        success: true,
        data: { id },
    };
}

}

/**
 * Handle search command
 */
export async function handleSearch(
    service: MemoryService,
    request: SearchRequest
): Promise<StdioResponse> {
    // Validate request
    const parsed = SearchSchema.safeParse(request);
    if (!parsed.success) {
        return {
            success: false,
            error: "Invalid search request",
            code: "VALIDATION_ERROR",
        };
    }

    // Search memories
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

}

/**
 * Handle get command
 */
export async function handleGet(
    service: MemoryService,
    request: GetRequest
): Promise<StdioResponse> {
    // Validate request
    const parsed = GetSchema.safeParse(request);
    if (!parsed.success) {
        return {
            success: false,
            error: "Invalid get request",
            code: "VALIDATION_ERROR",
        };
    }

    // Get memory
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
}

/**
 * Handle list command
 */
export async function handleList(
    service: MemoryService,
    request: ListRequest
): Promise<StdioResponse> {
    // Validate request
    const parsed = ListSchema.safeParse(request);
    if (!parsed.success) {
        return {
            success: false,
            error: "Invalid list request",
            code: "VALIDATION_ERROR",
        }
    }

    // List memories
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

}

/**
 * Handle delete command
 */
export async function handleDelete(
    service: MemoryService,
    request: DeleteRequest
): Promise<StdioResponse> {
    // Validate request
    const parsed = DeleteSchema.safeParse(request);
    if (!parsed.success) {
        return {
            success: false,
            error: "Invalid delete request",
            code: "VALIDATION_ERROR",
        }
    }

    // Delete memory
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

}

/**
 * Handle context command
 */
export async function handleContext(
    service: MemoryService,
    request: ContextRequest
): Promise<StdioResponse> {
    // Validate request
    const parsed = ContextSchema.safeParse(request);
    if (!parsed.success) {
        return {
            success: false,
            error: "Invalid context request",
            code: "VALIDATION_ERROR",
        }
    }

    // Get context for query
    const context = await service.getContext(request.query, {
        maxTokens: request.maxTokens,
        project: request.project,
    });

    return {
        success: true,
        data: context,
    };
}
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
