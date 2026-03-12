/**
 * Self-test for CLI test helper
 *
 * Verifies that all helper functions work correctly.
 */

import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import {
  setupTestDb,
  createTestMemories,
  assertFileExists,
  assertFileNotExists,
  assertJsonFileValid,
} from "./setup.js";
import { writeFile, mkdir } from "node:fs/promises";
import { join } from "node:path";

describe("CLI Test Helper", () => {
  describe("setupTestDb", () => {
    test("creates temp directory and returns cleanup", async () => {
      const { dbPath, service, cleanup } = await setupTestDb("setup-test-1");

      expect(dbPath).toBeDefined();
      expect(dbPath).toContain("test-data-cli");
      expect(service).toBeDefined();

      // Verify directory exists
      await assertFileExists(dbPath);

      // Cleanup
      await cleanup();

      // Verify cleanup removed directory
      await assertFileNotExists(dbPath);
    });

    test("cleanup removes temp directory", async () => {
      const { dbPath, cleanup } = await setupTestDb("setup-test-2");

      await assertFileExists(dbPath);
      await cleanup();
      await assertFileNotExists(dbPath);
    });

    test("creates unique paths for different test IDs", async () => {
      const db1 = await setupTestDb("unique-test-1");
      const db2 = await setupTestDb("unique-test-2");

      expect(db1.dbPath).not.toBe(db2.dbPath);

      await db1.cleanup();
      await db2.cleanup();
    });

    test("service can store memories", async () => {
      const { service, cleanup } = await setupTestDb("service-test");

      const entry = await service.store("Test content", { tags: ["test"] });
      expect(entry.id).toBeDefined();
      expect(entry.content).toBe("Test content");

      await cleanup();
    });
  });

  describe("createTestMemories", () => {
    test("creates N memories with defaults", async () => {
      const { service, cleanup } = await setupTestDb("memories-default");

      const memories = await createTestMemories(service, 3);

      expect(memories.length).toBe(3);
      expect(memories[0].content).toBe("Test memory 1");
      expect(memories[1].content).toBe("Test memory 2");
      expect(memories[2].content).toBe("Test memory 3");

      await cleanup();
    });

    test("accepts tags option", async () => {
      const { service, cleanup } = await setupTestDb("memories-tags");

      const memories = await createTestMemories(service, 2, {
        tags: ["alpha", "beta"],
      });

      expect(memories.length).toBe(2);
      expect(memories[0].tags).toEqual(["alpha", "beta"]);
      expect(memories[1].tags).toEqual(["alpha", "beta"]);

      await cleanup();
    });

    test("accepts project option", async () => {
      const { service, cleanup } = await setupTestDb("memories-project");

      const memories = await createTestMemories(service, 2, {
        project: "my-project",
      });

      expect(memories.length).toBe(2);
      expect(memories[0].project).toBe("my-project");
      expect(memories[1].project).toBe("my-project");

      await cleanup();
    });

    test("accepts contentPrefix option", async () => {
      const { service, cleanup } = await setupTestDb("memories-prefix");

      const memories = await createTestMemories(service, 2, {
        contentPrefix: "Custom memory",
      });

      expect(memories[0].content).toBe("Custom memory 1");
      expect(memories[1].content).toBe("Custom memory 2");

      await cleanup();
    });

    test("creates zero memories when count is 0", async () => {
      const { service, cleanup } = await setupTestDb("memories-zero");

      const memories = await createTestMemories(service, 0);
      expect(memories.length).toBe(0);

      await cleanup();
    });
  });

  describe("assertFileExists", () => {
    test("passes for existing file", async () => {
      const testDir = join(import.meta.dirname, "../../test-assert-exists");
      await mkdir(testDir, { recursive: true });
      const testFile = join(testDir, "exists.txt");
      await writeFile(testFile, "test content");

      // Should not throw
      await expect(assertFileExists(testFile)).resolves.toBeUndefined();

      // Cleanup
      await import("node:fs/promises").then((fs) => fs.rm(testDir, { recursive: true }));
    });

    test("throws for missing file", async () => {
      const missingFile = join(import.meta.dirname, "non-existent-file.txt");

      await expect(assertFileExists(missingFile)).rejects.toThrow("File does not exist");
    });
  });

  describe("assertFileNotExists", () => {
    test("passes for missing file", async () => {
      const missingFile = join(import.meta.dirname, "definitely-not-a-file.txt");

      // Should not throw
      await expect(assertFileNotExists(missingFile)).resolves.toBeUndefined();
    });

    test("throws for existing file", async () => {
      const testDir = join(import.meta.dirname, "../../test-assert-not-exists");
      await mkdir(testDir, { recursive: true });
      const testFile = join(testDir, "exists.txt");
      await writeFile(testFile, "test content");

      await expect(assertFileNotExists(testFile)).rejects.toThrow("should not exist");

      // Cleanup
      await import("node:fs/promises").then((fs) => fs.rm(testDir, { recursive: true }));
    });
  });

  describe("assertJsonFileValid", () => {
    test("parses valid JSON file", async () => {
      const testDir = join(import.meta.dirname, "../../test-json-valid");
      await mkdir(testDir, { recursive: true });
      const testFile = join(testDir, "valid.json");
      await writeFile(testFile, JSON.stringify({ foo: "bar", num: 42 }));

      const result = (await assertJsonFileValid(testFile)) as { foo: string; num: number };

      expect(result.foo).toBe("bar");
      expect(result.num).toBe(42);

      // Cleanup
      await import("node:fs/promises").then((fs) => fs.rm(testDir, { recursive: true }));
    });

    test("throws for invalid JSON file", async () => {
      const testDir = join(import.meta.dirname, "../../test-json-invalid");
      await mkdir(testDir, { recursive: true });
      const testFile = join(testDir, "invalid.json");
      await writeFile(testFile, "{ not valid json }");

      await expect(assertJsonFileValid(testFile)).rejects.toThrow("Invalid JSON");

      // Cleanup
      await import("node:fs/promises").then((fs) => fs.rm(testDir, { recursive: true }));
    });

    test("throws for missing file", async () => {
      const missingFile = join(import.meta.dirname, "missing.json");

      await expect(assertJsonFileValid(missingFile)).rejects.toThrow("File does not exist");
    });
  });
});
