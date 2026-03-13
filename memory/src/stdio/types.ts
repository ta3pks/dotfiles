import { z } from "zod";

// Request/Response types
export interface StdioRequest {
  command: "store" | "search" | "get" | "list" | "delete" | "context";
  [key: string]: any;
}

export interface StdioResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  code?: string;
}

// Command interfaces
export interface StoreCommand {
  command: "store";
  content: string;
  tags?: string[];
  project?: string;
}

export interface SearchCommand {
  command: "search";
  query: string;
  limit?: number;
  project?: string;
  tags?: string[];
}

export interface GetCommand {
  command: "get";
  id: string;
}

export interface ListCommand {
  command: "list";
  project?: string;
  tag?: string;
  limit?: number;
  offset?: number;
}

export interface DeleteCommand {
  command: "delete";
  id: string;
}

export interface ContextCommand {
  command: "context";
  query: string;
  maxTokens?: number;
  project?: string;
}

// Zod schemas for validation
export const StoreSchema = z.object({
  command: z.literal("store"),
  content: z.string().min(1),
  tags: z.array(z.string()).optional(),
  project: z.string().optional(),
});

export const SearchSchema = z.object({
  command: z.literal("search"),
  query: z.string().min(1),
  limit: z.number().int().positive().max(100).optional(),
  project: z.string().optional(),
  tags: z.array(z.string()).optional(),
});

export const GetSchema = z.object({
  command: z.literal("get"),
  id: z.string().min(1),
});

export const ListSchema = z.object({
  command: z.literal("list"),
  project: z.string().optional(),
  tag: z.string().optional(),
  limit: z.number().int().positive().max(1000).optional(),
  offset: z.number().int().nonnegative().optional(),
});

export const DeleteSchema = z.object({
  command: z.literal("delete"),
  id: z.string().min(1),
});

export const ContextSchema = z.object({
  command: z.literal("context"),
  query: z.string().min(1),
  maxTokens: z.number().int().positive().optional(),
  project: z.string().optional(),
});
