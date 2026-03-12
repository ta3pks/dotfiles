/**
 * Pattern type handler - stores code patterns with language field
 */

import type { PatternInput } from './index.js';
import { CLIError } from '../errors.js';
import { KNOWN_LANGUAGES } from './index.js';

export const typeName = 'pattern';
export const description = 'Code patterns with language-specific syntax and structure';

/**
 * Validates pattern input
 */
export function validate(input: Partial<PatternInput>): void {
  if (!input.content?.trim()) {
    throw new CLIError('Content is required');
  }
  if (!input.language?.trim()) {
    throw new CLIError('Language is required for pattern type. Use --language option.');
  }
  
  // Validate language is known (case-insensitive)
  const normalizedLang = input.language.toLowerCase();
  const isKnown = KNOWN_LANGUAGES.some(lang => lang.toLowerCase() === normalizedLang);
  if (!isKnown) {
    // Allow unknown languages but warn in validation (not enforced)
    // Could add validation here if strict mode needed
  }
}

/**
 * Gets default tags for pattern type
 */
export function getDefaultTags(input: PatternInput): string[] {
  const tags = ['pattern'];
  if (input.language) {
    tags.push(input.language.toLowerCase());
  }
  return tags;
}

/**
 * Formats content for pattern display
 */
export function formatContent(input: PatternInput): string {
  return `Pattern (${input.language}):\n${input.content}`;
}

/**
 * Interactive prompts for pattern type
 */
export function getInteractivePrompts(): Array<{
  name: string;
  message: string;
  type: string;
  default?: string;
  validate?: (input: string) => boolean | string;
}> {
  return [
    {
      name: 'language',
      message: 'Programming language:',
      type: 'input',
      validate: (input: string) => input.trim().length > 0 || 'Language is required'
    }
  ];
}

/**
 * Type-specific CLI options
 */
export const cliOptions = [
  {
    flags: '-l, --language <language>',
    description: 'Programming language for the pattern (required)'
  }
];
