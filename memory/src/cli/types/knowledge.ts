/**
 * Knowledge type handler - stores cross-project knowledge
 */

import type { KnowledgeInput } from './index.js';
import { CLIError } from '../errors.js';

export const typeName = 'knowledge';
export const description = 'Cross-project knowledge and best practices';

/**
 * Validates knowledge input
 */
export function validate(input: Partial<KnowledgeInput>): void {
  if (!input.content?.trim()) {
    throw new CLIError('Content is required');
  }
  // domain is optional for knowledge
}

/**
 * Gets default tags for knowledge type
 */
export function getDefaultTags(input: KnowledgeInput): string[] {
  const tags = ['knowledge'];
  if (input.domain) {
    tags.push(`domain:${input.domain}`);
  }
  return tags;
}

/**
 * Gets default project for knowledge type - defaults to 'global'
 */
export function getDefaultProject(): string {
  return 'global';
}

/**
 * Formats content for knowledge display
 */
export function formatContent(input: KnowledgeInput): string {
  let formatted = input.content;
  if (input.domain) {
    formatted = `[Domain: ${input.domain}]\n${formatted}`;
  }
  return formatted;
}

/**
 * Interactive prompts for knowledge type
 */
export function getInteractivePrompts(): Array<{
  name: string;
  message: string;
  type?: string;
}> {
  return [
    {
      name: 'domain',
      message: 'Knowledge domain (e.g., security, performance, architecture):',
      type: 'input'
    }
  ];
}

/**
 * Type-specific CLI options
 */
export const cliOptions = [
  {
    flags: '-d, --domain <domain>',
    description: 'Knowledge domain for categorization'
  }
];
