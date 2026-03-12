/**
 * Memory type definitions and zod interfaces for type handlers
 */
export interface BaseMemoryInput {
  content: string;
  tags?: string[];
  project?: string | null;
}

 
export interface BaseMemoryHandler<T extends BaseMemoryInput> {
  /**
   * Type name for this memory type
   */
  readonly typeName: string;
  
  /**
   * Type description for help/documentation
   */
  readonly description: string;
  
  /**
   * Validate input for this memory type
   * @param input The input to validate
   * @throws CLIError if validation fails
   */
  validate(input: T): void | input is T;
  
  /**
   * Get default tags for this memory type
   * @param input The input to get defaults for
   * @returns Array of default tags
   */
  getDefaultTags(input: T): string[];
  
  /**
   * Format content for this memory type
   * @param input The input to format
   * @returns Formatted content string
   */
  formatContent(input: T): string;
  
  /**
   * Interactive prompts for this memory type
   * @returns Array of prompt objects for interactive mode
   */
  getInteractivePrompts(): Array<{
    name: string;
    message: string;
    default?: string;
  }>;
}
