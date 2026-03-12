export interface SearchOptions {
  limit?: number;
  project?: string;
  tags?: string[];
}

export interface SearchOptions {
  limit?: number;
  project?: string;
  tags?: string[];
}

export interface ListOptions {
  project?: string;
  tag?: string;
  limit?: number;
  offset?: number;
}

export interface ContextOptions {
  maxTokens?: number;
  project?: string;
}

export interface ServiceError {
  code: string;
  message: string;
}
