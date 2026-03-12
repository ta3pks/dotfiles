/**
 * Decision type handler - stores project decisions with rationale
 */

import type { DecisionInput } from './index.js';
import { CLIError } from '../errors.js';

export const typeName = 'decision';
export const description = 'Project decisions with rationale explaining why a choice was made';

/**
 * Validates decision input
 */
export function validate(input: Partial<DecisionInput>): void {
  if (!input.content?.trim()) {
    throw new CLIError('Content is required');
  }
  if (!input.rationale?.trim()) {
    throw new CLIError('Rationale is required for decision type');
  }
}

/**
 * Gets default tags for decision type
 */
export function getDefaultTags(_input: DecisionInput): string[] {
  return ['decision'];
}

/**
 * Formats content for decision display
 */
export function formatContent(input: DecisionInput): string {
  let formatted = input.content;
  if (input.rationale) {
    formatted += `\n\nRationale: ${input.rationale}`;
  }
  return formatted;
}

/**
 * Interactive prompts for decision type
 */
export function getInteractivePrompts(): Array<{
  name: string;
  message: string;
  type?: string;
  validate?: (input: string) => boolean | string;
}> {
  return [
    {
      name: 'rationale',
      message: 'Rationale for this decision:',
      type: 'input',
      validate: (input: string) => input.trim().length > 0 || 'Rationale is required'
    }
  ];
}

/**
 * Type-specific CLI options
 */
export const cliOptions = [
  {
    flags: '-r, --rationale <text>',
    description: 'Rationale explaining why this decision was made (required)'
  }
];
