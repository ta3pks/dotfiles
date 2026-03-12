/**
 * Test Helper for CLI Tests
 *
 * Provides shared test fixtures and utilities for CLI command tests.
 * Creates isolated test environments with predictable memory data.
 */

import { mkdir, rm, access, readFile } from "node:fs/promises";
import { join } from "node:path";
import { MemoryService } from "../../../src/core/index.js";
import type { MemoryEntry } from "../../../src/storage/types.js";

/**
 * Result of setting up a test database
 */
export interface TestDbResult {
  /** Path to the test database directory */
  dbPath: string;
  /** Memory service instance configured for the test database */
  service: MemoryService;
  /** Cleanup function to remove test artifacts */
  cleanup: () => Promise<void>;
}

/**
 * Options for creating test memories
 */
export interface CreateMemoriesOptions {
  /** Tags to apply to all memories */
  tags?: string[];
  /** Project to assign to all memories */
  project?: string;
  /** Prefix for memory content (default: "Test memory") */
  contentPrefix?: string;
}

/**
 * Creates an isolated test database environment
 *
 * @param testId - Unique identifier for this test run (default: random timestamp)
 * @returns Test database path, service instance, and cleanup function
 */
export async function setupTestDb(testId?: string): Promise<TestDbResult> {
  const id = testId || `test-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
  const dbPath = join(import.meta.dirname, `../../../test-data-cli-${id}`);

  // Clean up any existing test data
  await rm(dbPath, { recursive: true, force: true });

  // Create fresh test directory
  await mkdir(dbPath, { recursive: true });

  // Initialize memory service with test path
  const service = new MemoryService();
  await service.init(dbPath);

  return {
    dbPath,
    service,
    cleanup: async () => {
      await rm(dbPath, { recursive: true, force: true }).catch(() => {});
    },
  };
}

/**
 * Creates N test memories with predictable content
 *
 * @param service - MemoryService instance to use
 * @param count - Number of memories to create
 * @param options - Optional tags and project assignment
 * @returns Array of created memory entries
 */
export async function createTestMemories(
  service: MemoryService,
  count: number,
  options?: CreateMemoriesOptions
): Promise<MemoryEntry[]> {
  const entries: MemoryEntry[] = [];
  const prefix = options?.contentPrefix || "Test memory";

  for (let i = 0; i < count; i++) {
    const entry = await service.store(`${prefix} ${i + 1}`, {
      tags: options?.tags || [],
      project: options?.project || null,
    });
    entries.push(entry);
  }

  return entries;
}

/**
 * Asserts that a file exists at the given path
 *
 * @param filePath - Path to check
 * @throws Error if file doesn't exist
 */
export async function assertFileExists(filePath: string): Promise<void> {
  try {
    await access(filePath);
  } catch {
    throw new Error(`File does not exist: ${filePath}`);
  }
}

/**
 * Reads and parses a JSON file, throwing if invalid
 *
 * @param filePath - Path to JSON file
 * @returns Parsed JSON object
 * @throws Error if file doesn't exist or contains invalid JSON
 */
export async function assertJsonFileValid(filePath: string): Promise<unknown> {
  try {
    const content = await readFile(filePath, "utf-8");
    return JSON.parse(content);
  } catch (error) {
    if (error instanceof Error) {
      if (error.message.includes("ENOENT")) {
        throw new Error(`File does not exist: ${filePath}`);
      }
      if (error instanceof SyntaxError) {
        throw new Error(`Invalid JSON in file: ${filePath} - ${error.message}`);
      }
    }
    throw error;
  }
}

/**
 * Asserts that a file does NOT exist
 *
 * @param filePath - Path to check
 * @throws Error if file exists
 */
export async function assertFileNotExists(filePath: string): Promise<void> {
  try {
    await access(filePath);
    throw new Error(`File should not exist: ${filePath}`);
  } catch (error) {
    if (error instanceof Error && error.message.includes("should not exist")) {
      throw error;
    }
    // File doesn't exist, which is what we want
  }
}

/**
 * Waits for a condition to be true
 *
 * @param condition - Async function that returns true when condition is met
 * @param timeout - Maximum time to wait in milliseconds (default: 5000)
 * @param interval - Check interval in milliseconds (default: 100)
 */
export async function waitFor(
  condition: () => Promise<boolean>,
  timeout = 5000,
  interval = 100
): Promise<void> {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    if (await condition()) {
      return;
    }
    await new Promise((resolve) => setTimeout(resolve, interval));
  }
  throw new Error(`Timeout waiting for condition after ${timeout}ms`);
}
