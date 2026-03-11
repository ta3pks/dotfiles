import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import {
  initMemoryService,
  storeMemory,
  searchMemories,
  retrieveMemory,
  listAllMemories,
  removeMemory,
  closeMemoryService,
  isInitialized
} from "../../src/memory/index.js";
import { rm, mkdir } from "fs/promises";
import { join } from "path";

const TEST_DATA_PATH = join(import.meta.dir, "..", "fixtures", "test_data");

describe("Memory Service", () => {
  beforeEach(async () => {
    await rm(TEST_DATA_PATH, { recursive: true, force: true });
    await mkdir(TEST_DATA_PATH, { recursive: true });
  });

  afterEach(async () => {
    if (isInitialized()) {
      await closeMemoryService();
    }
  });

  test("initializes memory service", async () => {
    await initMemoryService({ dataPath: TEST_DATA_PATH });
    expect(isInitialized()).toBe(true);
  });

  test("stores memory with auto-embedding", async () => {
    await initMemoryService({ dataPath: TEST_DATA_PATH });
    
    const id = await storeMemory({
      content: "This is a test memory about TypeScript patterns",
      tags: ["typescript", "patterns"],
      project: "test-project"
    });
    
    expect(id).toHaveLength(12);
    
    const retrieved = retrieveMemory(id);
    expect(retrieved).not.toBeNull();
    expect(retrieved?.content).toBe("This is a test memory about TypeScript patterns");
    expect(retrieved?.tags).toEqual(["typescript", "patterns"]);
    expect(retrieved?.project).toBe("test-project");
    expect(retrieved?.embeddingModel).toBe("nomic-embed-text");
  });

  test("searches memories semantically", async () => {
    await initMemoryService({ dataPath: TEST_DATA_PATH });
    
    await storeMemory({
      content: "React hooks are functions that let you use state in functional components",
      tags: ["react", "hooks"]
    });
    
    await storeMemory({
      content: "TypeScript generics provide type safety for reusable components",
      tags: ["typescript", "generics"]
    });
    
    const results = await searchMemories("how to use state in React components");
    
    expect(results.length).toBeGreaterThan(0);
    const reactResult = results.find(r => r.tags.includes("react"));
    expect(reactResult).toBeDefined();
  });

  test("lists memories by project", async () => {
    await initMemoryService({ dataPath: TEST_DATA_PATH });
    
    await storeMemory({
      content: "Project A note",
      project: "project-a"
    });
    
    await storeMemory({
      content: "Project B note",
      project: "project-b"
    });
    
    const projectAMemories = listAllMemories({ project: "project-a" });
    expect(projectAMemories.length).toBe(1);
    expect(projectAMemories[0].project).toBe("project-a");
  });

  test("removes memory from both databases", async () => {
    await initMemoryService({ dataPath: TEST_DATA_PATH });
    
    const id = await storeMemory({
      content: "Memory to delete"
    });
    
    const deleted = await removeMemory(id);
    expect(deleted).toBe(true);
    
    const retrieved = retrieveMemory(id);
    expect(retrieved).toBeNull();
  });
});
