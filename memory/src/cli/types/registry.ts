/**
 * Type registry - dispatches to correct type handler
 */

import type { MemoryType, TypedMemoryInput, BaseMemoryInput } from './index.js';
import * as pattern from './pattern.js';
import * as decision from './decision.js';
import * as context from './context.js';
import * as knowledge from './knowledge.js';
import * as preference from './preference.js';

export interface TypeHandler {
  typeName: string;
  description: string;
  validate: (input: Partial<TypedMemoryInput>) => void;
  getDefaultTags: (input: TypedMemoryInput) => string[];
  getDefaultProject?: () => string;
  formatContent: (input: TypedMemoryInput) => string;
  getInteractivePrompts?: () => Array<{
    name: string;
    message: string;
    type?: string;
    validate?: (input: string) => boolean | string;
    default?: string;
  }>;
  cliOptions: Array<{
    flags: string;
    description: string;
  }>;
}

const handlers: Record<string, TypeHandler> = {
  pattern: pattern as unknown as TypeHandler,
  decision: decision as unknown as TypeHandler,
  context: context as unknown as TypeHandler,
  knowledge: knowledge as unknown as TypeHandler,
  preference: preference as unknown as TypeHandler
};

/**
 * Get the handler for a specific memory type
 */
export function getHandler(type: MemoryType): TypeHandler | undefined {
  return handlers[type];
}

/**
 * Check if a type is valid
 */
export function isValidType(type: string): type is MemoryType {
  return type in handlers || type === 'note';
}

/**
 * Get all available type names
 */
export function getAvailableTypes(): string[] {
  return [...Object.keys(handlers), 'note'];
}

/**
 * Validate input for a specific type
 */
export function validateInput(type: MemoryType, input: Partial<TypedMemoryInput>): void {
  const handler = getHandler(type);
  if (handler) {
    handler.validate(input);
  } else if (type === 'note') {
    // Default note type - just requires content
    if (!input.content?.trim()) {
      const { CLIError } = require('../errors.js');
      throw new CLIError('Content is required');
    }
  }
}

/**
 * Get interactive prompts for a type
 */
export function getInteractivePrompts(type: MemoryType): Array<{
  name: string;
  message: string;
  type?: string;
  validate?: (input: string) => boolean | string;
  default?: string;
}> {
  const handler = getHandler(type);
  if (handler?.getInteractivePrompts) {
    return handler.getInteractivePrompts();
  }
  return [];
}

/**
 * Get default tags for a type
 */
export function getDefaultTags(type: MemoryType, input: TypedMemoryInput): string[] {
  const handler = getHandler(type);
  if (handler) {
    return handler.getDefaultTags(input);
  }
  // Default for 'note' type
  return ['note'];
}

/**
 * Get default project for a type
 */
export function getDefaultProject(type: MemoryType): string | undefined {
  const handler = getHandler(type);
  if (handler?.getDefaultProject) {
    return handler.getDefaultProject();
  }
  return undefined;
}

/**
 * Format content for display based on type
 */
export function formatContent(type: MemoryType, input: TypedMemoryInput): string {
  const handler = getHandler(type);
  if (handler) {
    return handler.formatContent(input);
  }
  return input.content;
}

/**
 * Get CLI options for all types (for help text)
 */
export function getAllCliOptions(): Record<string, Array<{ flags: string; description: string }>> {
  const result: Record<string, Array<{ flags: string; description: string }>> = {};
  
  for (const [typeName, handler] of Object.entries(handlers)) {
    result[typeName] = handler.cliOptions;
  }
  
  return result;
}

/**
 * Get type description for help
 */
export function getTypeDescription(type: MemoryType): string {
  const handler = getHandler(type);
  if (handler) {
    return handler.description;
  }
  return 'Generic memory note';
}

// Re-export types
export { MemoryType, TypedMemoryInput, BaseMemoryInput } from './index.js';
