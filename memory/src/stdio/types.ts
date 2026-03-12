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
