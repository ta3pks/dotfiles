import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import { initMetaStore, insertMemory, getMemory, listMemories, deleteMemory, closeMetaStore } from "../../src/storage/sqlite.js";
import { rm, mkdir } from "fs/promises";
import { join } from "path";

const TEST_DB_PATH = join(import.meta.dir, "..", "fixtures", "test_meta.sqlite");
const FIXTURES_DIR = join(import.meta.dir, "..", "fixtures");

describe("SQLite Metadata Store", () => {
  beforeEach(async () => {
    await rm(FIXTURES_DIR, { recursive: true, force: true });
    await mkdir(FIXTURES_DIR, { recursive: true });
  });

  afterEach(() => {
    closeMetaStore();
  });

  test("initializes metadata store with WAL mode", () => {
    const db = initMetaStore(TEST_DB_PATH);
    expect(db).toBeDefined();
    
    const mode = db.query("PRAGMA journal_mode").get() as any;
    expect(mode.journal_mode).toBe("wal");
  });

  test("inserts and retrieves memories", () => {
    initMetaStore(TEST_DB_PATH);
    
    const entry = {
      id: "test-001",
      content: "Test memory content",
      tags: ["test", "unit"],
      project: "test-project",
      createdAt: Date.now(),
      embeddingModel: "nomic-embed-text"
    };
    
    insertMemory(entry);
    
    const retrieved = getMemory("test-001");
    expect(retrieved).not.toBeNull();
    expect(retrieved?.content).toBe("Test memory content");
    expect(retrieved?.tags).toEqual(["test", "unit"]);
  });

  test("lists memories with filters", () => {
    initMetaStore(TEST_DB_PATH);
    
    insertMemory({
      id: "test-002",
      content: "Project A memory",
      tags: [],
      project: "project-a",
      createdAt: Date.now(),
      embeddingModel: "nomic-embed-text"
    });
    
    insertMemory({
      id: "test-003",
      content: "Project B memory",
      tags: [],
      project: "project-b",
      createdAt: Date.now(),
      embeddingModel: "nomic-embed-text"
    });
    
    const projectAMemories = listMemories({ project: "project-a" });
    expect(projectAMemories.length).toBe(1);
    expect(projectAMemories[0].project).toBe("project-a");
  });

  test("deletes memories", () => {
    initMetaStore(TEST_DB_PATH);
    
    insertMemory({
      id: "test-004",
      content: "To be deleted",
      tags: [],
      project: null,
      createdAt: Date.now(),
      embeddingModel: "nomic-embed-text"
    });
    
    const deleted = deleteMemory("test-004");
    expect(deleted).toBe(true);
    
    const retrieved = getMemory("test-004");
    expect(retrieved).toBeNull();
  });
});
