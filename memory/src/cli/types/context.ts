/**
 * Context type handler - stores conversation context
 */

import type { ContextInput } from './index.js';
import { CLIError } from '../errors.js';

export const typeName = 'context';
export const description = 'Conversation context and session information';

/**
 * Validates context input
 */
export function validate(input: Partial<ContextInput>): void {
  if (!input.content?.trim()) {
    throw new CLIError('Content is required');
  }
  // sessionId is optional for context
}

/**
 * Gets default tags for context type
 */
export function getDefaultTags(input: ContextInput): string[] {
  const tags = ['context'];
  if (input.sessionId) {
    tags.push(`session:${input.sessionId}`);
  }
  return tags;
}

/**
 * Formats content for context display - adds timestamp
 */
export function formatContent(input: ContextInput): string {
  const timestamp = new Date().toISOString();
  let formatted = `[${timestamp}]\n${input.content}`;
  if (input.sessionId) {
    formatted = `[Session: ${input.sessionId}] ${formatted}`;
  }
  return formatted;
}

/**
 * Interactive prompts for context type
 */
export function getInteractivePrompts(): Array<{
  name: string;
  message: string;
  type?: string;
}> {
  return [
    {
      name: 'sessionId',
      message: 'Session ID (optional):',
      type: 'input'
    }
  ];
}

/**
 * Type-specific CLI options
 */
export const cliOptions = [
  {
    flags: '-s, --session-id <id>',
    description: 'Session identifier for grouping related context'
  }
];
