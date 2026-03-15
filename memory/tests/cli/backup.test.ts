import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import { join } from "node:path";
import { access, readdir, stat } from "node:fs/promises";
import { setupTestDb, createTestMemories, assertFileExists, assertFileNotExists } from "./helpers/setup.js";
import { registerBackupCommand } from "../../src/cli/commands/backup.js";
import { Command } from "commander";
import { MemoryService } from "../../src/core/index.js";
import type { TestDbResult } from "./helpers/setup.js";

describe("Backup Command", () => {
  let testDb: TestDbResult;
  let backupDir: string;

  beforeEach(async () => {
    testDb = await setupTestDb("backup-test");
    backupDir = join(testDb.dbPath, "backups");
    
    // Create some test memories
    await createTestMemories(testDb.service, 5, {
      tags: ["test"],
      project: "backup-test"
    });
  });

  afterEach(async () => {
    await testDb.cleanup();
  });

  describe("backup", () => {
    test("creates timestamped backup file", async () => {
      const program = new Command();
      program.exitOverride();
      registerBackupCommand(program);
      
      await program.parseAsync(["backup", "-o", backupDir], { from: "user" });
      
      // Verify backup file was created
      const files = await readdir(backupDir);
      const backupFiles = files.filter(f => f.startsWith("memory-backup-") && f.endsWith(".db"));
      
      expect(backupFiles.length).toBe(1);
      
      // Verify backup file is a valid size
      const backupPath = join(backupDir, backupFiles[0]);
      const stats = await stat(backupPath);
      expect(stats.size).toBeGreaterThan(0);
    });

    test("respects --output option", async () => {
      const customDir = join(testDb.dbPath, "custom-backups");
      const program = new Command();
      program.exitOverride();
      registerBackupCommand(program);
      
      await program.parseAsync(["backup", "-o", customDir], { from: "user" });
      
      // Verify backup was created in custom directory
      const files = await readdir(customDir);
      expect(files.some(f => f.startsWith("memory-backup-"))).toBe(true);
    });

    test("respects --name option", async () => {
      const program = new Command();
      program.exitOverride();
      registerBackupCommand(program);
      
      await program.parseAsync(["backup", "-o", backupDir, "-n", "custom-backup"], { from: "user" });
      
      // Verify custom named backup was created
      const files = await readdir(backupDir);
      expect(files.includes("custom-backup.db")).toBe(true);
    });

    test("rotates old backups with --max-backups", async () => {
      // Create 5 backups with max-backups=3
      for (let i = 0; i < 5; i++) {
        const cmd = new Command();
        cmd.exitOverride();
        registerBackupCommand(cmd);
        await cmd.parseAsync(["backup", "-o", backupDir, "-n", `backup-${i}`, "-m", "3"], { from: "user" });
      }
      
      // Should only have 3 backups
      const files = await readdir(backupDir);
      const backupFiles = files.filter(f => f.startsWith("backup-") && f.endsWith(".db"));
      expect(backupFiles.length).toBe(3);
      
      // Should have kept the most recent (2, 3, 4)
      expect(backupFiles.includes("backup-2.db")).toBe(true);
      expect(backupFiles.includes("backup-3.db")).toBe(true);
      expect(backupFiles.includes("backup-4.db")).toBe(true);
    });
  });

  describe("restore", () => {
    test("lists available backups with --list", async () => {
      const backupProgram = new Command();
      backupProgram.exitOverride();
      registerBackupCommand(backupProgram);
      
      // Create a backup first
      await backupProgram.parseAsync(["backup", "-o", backupDir], { from: "user" });
      
      // List backups
      const listProgram = new Command();
      listProgram.exitOverride();
      registerBackupCommand(listProgram);
      
      // Capture output
      const logs: string[] = [];
      const originalLog = console.log;
      console.log = (...args: any[]) => logs.push(args.join(" "));
      
      try {
        await listProgram.parseAsync(["backup", "restore", "-d", backupDir, "--list"], { from: "user" });
      } finally {
        console.log = originalLog;
      }
      
      // Verify output contains backup info
      const output = logs.join("\n");
      expect(output).toContain("memory-backup-");
    });

    test("restores database from backup", async () => {
      const backupProgram = new Command();
      backupProgram.exitOverride();
      registerBackupCommand(backupProgram);
      
      // Create backup with known content
      await backupProgram.parseAsync(["backup", "-o", backupDir, "-n", "test-restore"], { from: "user" });
      
      // Verify backup file was created
      const backupPath = join(backupDir, "test-restore.db");
      await assertFileExists(backupPath);
      
      // Set MEMORY_DATA_PATH so restore targets the test database
      const originalEnv = process.env.MEMORY_DATA_PATH;
      process.env.MEMORY_DATA_PATH = testDb.dbPath;
      
      try {
        // Restore from backup (with --yes to skip confirmation)
        const restoreProgram = new Command();
        restoreProgram.exitOverride();
        registerBackupCommand(restoreProgram);
        await restoreProgram.parseAsync(["backup", "restore", "-f", backupPath, "--yes"], { from: "user" });
        
        // Verify restore succeeded by checking the file was copied
        // Note: Full data verification is complex due to SQLite WAL mode
        // The restore command copies the backup file to the database location
        const dbPath = join(testDb.dbPath, "metadata.sqlite");
        await assertFileExists(dbPath);
        
        // Verify the restored file has content (backup file size)
        const backupStats = await stat(backupPath);
        const dbStats = await stat(dbPath);
        expect(dbStats.size).toBe(backupStats.size);
      } finally {
        // Restore original environment
        if (originalEnv === undefined) {
          delete process.env.MEMORY_DATA_PATH;
        } else {
          process.env.MEMORY_DATA_PATH = originalEnv;
        }
      }
    });

    test("validates backup file before restore", async () => {
      const invalidFile = join(testDb.dbPath, "invalid.db");
      
      // Create a non-SQLite file
      const { writeFile } = await import("node:fs/promises");
      await writeFile(invalidFile, "not a sqlite file");
      
      // Should throw validation error
      const restoreProgram = new Command();
      restoreProgram.exitOverride();
      registerBackupCommand(restoreProgram);
      
      let errorThrown = false;
      try {
        await restoreProgram.parseAsync(["backup", "restore", "-f", invalidFile, "--yes"], { from: "user" });
      } catch (err) {
        errorThrown = true;
        expect(err).toBeDefined();
      }
      
      expect(errorThrown).toBe(true);
    });
  });
});
