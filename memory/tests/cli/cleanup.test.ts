import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import { setupTestDb, createTestMemories } from "./helpers/setup.js";
import { registerCleanupCommand } from "../../src/cli/commands/cleanup.js";
import { Command } from "commander";
import type { TestDbResult } from "./helpers/setup.js";

describe("Cleanup Command", () => {
  let testDb: TestDbResult;

  beforeEach(async () => {
    testDb = await setupTestDb("cleanup-test");
    
    // Create test memories with different ages and tags
    // Recent memories (today)
    await createTestMemories(testDb.service, 3, {
      tags: ["recent", "test"],
      project: "project-a",
      contentPrefix: "Recent memory"
    });
    
    // Old memories (we'll use tag to identify)
    await createTestMemories(testDb.service, 2, {
      tags: ["old", "test"],
      project: "project-b",
      contentPrefix: "Old memory"
    });
    
    // Mixed project memories
    await createTestMemories(testDb.service, 2, {
      tags: ["shared"],
      project: "shared-project",
      contentPrefix: "Shared memory"
    });
  });

  afterEach(async () => {
    await testDb.cleanup();
  });

  describe("--older-than filter", () => {
    test("filters memories by age threshold", async () => {
      const program = new Command();
      registerCleanupCommand(program);
      
      // Get initial count
      const before = await testDb.service.search("memory");
      const beforeCount = before.length;
      
      // Run cleanup with --dry-run to see what would be deleted
      const dryRunProgram = new Command();
      registerCleanupCommand(dryRunProgram);
      
      const logs: string[] = [];
      const originalLog = console.log;
      console.log = (...args: any[]) => logs.push(args.join(" "));
      
      try {
        await dryRunProgram.parseAsync([
          "node", "test", "cleanup",
          "--older-than", "0d", // Everything older than today
          "--dry-run"
        ], { from: "user" });
      } finally {
        console.log = originalLog;
      }
      
      const output = logs.join("\n");
      expect(output).toContain("Would delete");
    });

    test("supports various age formats", async () => {
      const formats = ["30d", "2w", "6m", "1y"];
      
      for (const format of formats) {
        const program = new Command();
        registerCleanupCommand(program);
        
        // Should not throw for valid formats
        const logs: string[] = [];
        const originalLog = console.log;
        console.log = (...args: any[]) => logs.push(args.join(" "));
        
        try {
          await program.parseAsync([
            "node", "test", "cleanup",
            "--older-than", format,
            "--dry-run"
          ], { from: "user" });
        } finally {
          console.log = originalLog;
        }
        
        // Should complete without error
        expect(true).toBe(true);
      }
    });

    test("rejects invalid age format", async () => {
      const program = new Command();
      registerCleanupCommand(program);
      
      let errorThrown = false;
      try {
        await program.parseAsync([
          "node", "test", "cleanup",
          "--older-than", "invalid",
          "--dry-run"
        ], { from: "user" });
      } catch (err) {
        errorThrown = true;
      }
      
      expect(errorThrown).toBe(true);
    });
  });

  describe("--tag filter", () => {
    test("filters memories by tag", async () => {
      const program = new Command();
      registerCleanupCommand(program);
      
      const logs: string[] = [];
      const originalLog = console.log;
      console.log = (...args: any[]) => logs.push(args.join(" "));
      
      try {
        await program.parseAsync([
          "node", "test", "cleanup",
          "--tag", "old",
          "--dry-run"
        ], { from: "user" });
      } finally {
        console.log = originalLog;
      }
      
      const output = logs.join("\n");
      expect(output).toContain("Would delete");
      expect(output).toContain("2"); // Should find 2 "old" tagged memories
    });
  });

  describe("--project filter", () => {
    test("filters memories by project", async () => {
      const program = new Command();
      registerCleanupCommand(program);
      
      const logs: string[] = [];
      const originalLog = console.log;
      console.log = (...args: any[]) => logs.push(args.join(" "));
      
      try {
        await program.parseAsync([
          "node", "test", "cleanup",
          "-p", "project-b",
          "--dry-run"
        ], { from: "user" });
      } finally {
        console.log = originalLog;
      }
      
      const output = logs.join("\n");
      expect(output).toContain("Would delete");
      expect(output).toContain("2"); // Should find 2 project-b memories
    });
  });

  describe("--dry-run", () => {
    test("shows what would be deleted without deleting", async () => {
      const before = await testDb.service.search("memory");
      
      const program = new Command();
      registerCleanupCommand(program);
      
      await program.parseAsync([
        "node", "test", "cleanup",
        "--tag", "test",
        "--dry-run"
      ], { from: "user" });
      
      // Verify nothing was actually deleted
      const after = await testDb.service.search("memory");
      expect(after.length).toBe(before.length);
    });
  });

  describe("--yes flag", () => {
    test("skips confirmation prompt", async () => {
      const before = await testDb.service.search("memory");
      const beforeCount = before.length;
      
      const program = new Command();
      registerCleanupCommand(program);
      
      await program.parseAsync([
        "node", "test", "cleanup",
        "--tag", "old",
        "--yes"
      ], { from: "user" });
      
      // Verify memories were deleted
      const after = await testDb.service.search("old");
      expect(after.length).toBe(0);
    });
  });

  describe("multi-criteria filtering", () => {
    test("combines tag and project filters", async () => {
      const program = new Command();
      registerCleanupCommand(program);
      
      const logs: string[] = [];
      const originalLog = console.log;
      console.log = (...args: any[]) => logs.push(args.join(" "));
      
      try {
        await program.parseAsync([
          "node", "test", "cleanup",
          "--tag", "test",
          "-p", "project-a",
          "--dry-run"
        ], { from: "user" });
      } finally {
        console.log = originalLog;
      }
      
      const output = logs.join("\n");
      expect(output).toContain("Would delete");
      // Should find only memories that have both "test" tag AND "project-a"
      expect(output).toContain("3"); // 3 recent memories in project-a
    });

    test("combines age and tag filters", async () => {
      const program = new Command();
      registerCleanupCommand(program);
      
      const logs: string[] = [];
      const originalLog = console.log;
      console.log = (...args: any[]) => logs.push(args.join(" "));
      
      try {
        await program.parseAsync([
          "node", "test", "cleanup",
          "--older-than", "1d",
          "--tag", "shared",
          "--dry-run"
        ], { from: "user" });
      } finally {
        console.log = originalLog;
      }
      
      const output = logs.join("\n");
      expect(output).toContain("Would delete");
    });
  });

  describe("validation", () => {
    test("requires at least one filter", async () => {
      const program = new Command();
      registerCleanupCommand(program);
      
      let errorThrown = false;
      try {
        await program.parseAsync([
          "node", "test", "cleanup",
          "--dry-run"
        ], { from: "user" });
      } catch (err) {
        errorThrown = true;
      }
      
      expect(errorThrown).toBe(true);
    });

    test("handles empty result set gracefully", async () => {
      const program = new Command();
      registerCleanupCommand(program);
      
      const logs: string[] = [];
      const originalLog = console.log;
      console.log = (...args: any[]) => logs.push(args.join(" "));
      
      try {
        await program.parseAsync([
          "node", "test", "cleanup",
          "--tag", "nonexistent-tag-xyz",
          "--dry-run"
        ], { from: "user" });
      } finally {
        console.log = originalLog;
      }
      
      const output = logs.join("\n");
      expect(output).toContain("No memories match");
    });
  });
});
