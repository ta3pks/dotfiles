/**
 * Preference type handler - stores user preferences
 */

import type { PreferenceInput } from './index.js';
import { CLIError } from '../errors.js';

export const typeName = 'preference';
export const description = 'User preferences and coding style choices';

/**
 * Validates preference input
 */
export function validate(input: Partial<PreferenceInput>): void {
  if (!input.content?.trim()) {
    throw new CLIError('Content is required');
  }
  // category is optional
}

/**
 * Gets default tags for preference type
 */
export function getDefaultTags(input: PreferenceInput): string[] {
  const tags = ['preference'];
  if (input.category) {
    tags.push(`category:${input.category}`);
  }
  return tags;
}

/**
 * Gets default project for preference type - defaults to 'global'
 */
export function getDefaultProject(): string {
  return 'global';
}

/**
 * Formats content for preference display
 */
export function formatContent(input: PreferenceInput): string {
  let formatted = input.content;
  if (input.category) {
    formatted = `[${input.category}] ${formatted}`;
  }
  return formatted;
}

/**
 * Interactive prompts for preference type
 */
export function getInteractivePrompts(): Array<{
  name: string;
  message: string;
  type?: string;
}> {
  return [
    {
      name: 'category',
      message: 'Preference category (e.g., style, formatting, tooling):',
      type: 'input'
    }
  ];
}

/**
 * Type-specific CLI options
 */
export const cliOptions = [
  {
    flags: '-c, --category <category>',
    description: 'Preference category for grouping'
  }
];
