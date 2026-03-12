/**
 * Memory type definitions and interfaces for type handlers
 */

export type MemoryType = 'pattern' | 'decision' | 'context' | 'knowledge' | 'preference' | 'note';

export interface BaseMemoryInput {
  content: string;
  tags?: string[];
  project?: string | null;
}

export interface PatternInput extends BaseMemoryInput {
  content: string;
  language: string;
  tags?: string[];
  project?: string;
}

export interface DecisionInput extends BaseMemoryInput {
  content: string;
  rationale: string;
  tags?: string[];
  project?: string;
}

export interface ContextInput extends BaseMemoryInput {
  content: string;
  sessionId?: string;
  tags?: string[];
  project?: string;
}

export interface KnowledgeInput extends BaseMemoryInput {
  content: string;
  domain?: string;
  tags?: string[];
  project?: string;
}

export interface PreferenceInput extends BaseMemoryInput {
  content: string;
  category?: string;
  tags?: string[];
  project?: string;
}

export type TypedMemoryInput = PatternInput | DecisionInput | ContextInput | KnowledgeInput | PreferenceInput | BaseMemoryInput;

// Type guards
export function isPatternInput(input: TypedMemoryInput): input is PatternInput {
  return 'language' in input && typeof input.language === 'string';
}

export function isDecisionInput(input: TypedMemoryInput): input is DecisionInput {
  return 'rationale' in input && typeof input.rationale === 'string';
}

export function isContextInput(input: TypedMemoryInput): input is ContextInput {
  return 'sessionId' in input;
}

export function isKnowledgeInput(input: TypedMemoryInput): input is KnowledgeInput {
  return 'domain' in input;
}

export function isPreferenceInput(input: TypedMemoryInput): input is PreferenceInput {
  return 'category' in input;
}

// Known programming languages for validation
export const KNOWN_LANGUAGES = [
  'typescript', 'javascript', 'python', 'rust', 'go', 'java', 'kotlin', 'swift',
  'c', 'cpp', 'csharp', 'ruby', 'php', 'scala', 'elixir', 'haskell', 'clojure',
  'lua', 'perl', 'r', 'julia', 'dart', 'bash', 'shell', 'sql', 'html', 'css',
  'scss', 'sass', 'less', 'json', 'yaml', 'toml', 'xml', 'markdown', 'dockerfile'
] as const;

export type ProgrammingLanguage = typeof KNOWN_LANGUAGES[number];

export const MEMORY_TYPES: MemoryType[] = ['pattern', 'decision', 'context', 'knowledge', 'preference', 'note'];
