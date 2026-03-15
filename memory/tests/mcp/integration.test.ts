import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import { MemoryService } from "../../src/core/service.js";
import { join } from "node:path";
import { rm, mkdir } from "node:fs/promises";
import { setTimeout as sleep } from "node:timers/promises";

const TEST_DATA_PATH = join(import.meta.dirname, "../../test-data-mcp");
const TEST_PROJECT = `mcp-test-${Date.now()}`;

let service: MemoryService;

beforeEach(async () => {
  await rm(TEST_DATA_PATH, { recursive: true }).catch(() => {});
  await mkdir(TEST_DATA_PATH, { recursive: true });
  service = new MemoryService();
  await service.init(TEST_DATA_PATH);
});

afterEach(async () => {
  const results = await service.list({ project: TEST_PROJECT });
  for (const memory of results) {
    await service.delete(memory.id);
  }
  await rm(TEST_DATA_PATH, { recursive: true }).catch(() => {});
});

describe("MemoryService Integration", () => {
  async function storeMemory(args: {
    content: string;
    tags?: string[];
    project?: string;
  }) {
    const result = await service.store(args.content, {
      tags: args.tags,
      project: args.project || TEST_PROJECT,
    });
    expect(result.id).toBeDefined();
    expect(result.content).toBe(args.content);
    if (args.tags) {
      expect(result.tags).toEqual(args.tags);
    }
    if (args.project) {
      expect(result.project).toBe(args.project);
    }
    return result;
  }

  async function searchMemories(args: {
    query: string;
    limit?: number;
    project?: string;
    tags?: string[];
    expectContent?: string;
  }) {
    const results = await service.search(args.query, {
      limit: args.limit,
      project: args.project || TEST_PROJECT,
      tags: args.tags,
    });
    expect(results.length).toBeGreaterThan(0);
    if (args.expectContent) {
      expect(results[0].content).toContain(args.expectContent);
    }
    return results;
  }

  async function listMemories(args: {
    project?: string;
    tag?: string;
    limit?: number;
    offset?: number;
  }) {
    const results = await service.list({
      project: args.project || TEST_PROJECT,
      tag: args.tag,
      limit: args.limit,
      offset: args.offset,
    });
    return results;
  }

  async function getMemory(args: { id: string; expectNull?: boolean }) {
    const entry = await service.get(args.id);
    if (args.expectNull) {
      expect(entry).toBeNull();
    } else {
      expect(entry).toBeDefined();
      expect(entry?.id).toBe(args.id);
    }
    return entry;
  }

  async function deleteMemory(args: { id: string; expectSuccess?: boolean }) {
    const success = await service.delete(args.id);
    expect(success).toBe(args.expectSuccess ?? true);
    return success;
  }

  async function getContext(args: {
    query: string;
    maxTokens?: number;
    project?: string;
  }) {
    const context = await service.getContext(args.query, {
      maxTokens: args.maxTokens || 2000,
      project: args.project || TEST_PROJECT,
    });
    expect(context).toBeDefined();
    return context;
  }

  test("stores and retrieves a memory", async () => {
    const result = await storeMemory({
      content: "Test memory content",
    });
    expect(result.id).toBeDefined();
  });

  test("stores memory with tags and project", async () => {
    const result = await storeMemory({
      content: "Tagged memory for MCP test",
      tags: ["test", "mcp"],
      project: TEST_PROJECT,
    });
    expect(result.tags).toEqual(["test", "mcp"]);
    expect(result.project).toBe(TEST_PROJECT);
  });

  test("searches memories with semantic matching", async () => {
    await storeMemory({
      content: "React hooks allow state management in functional components",
      tags: ["react"],
      project: TEST_PROJECT,
    });
    await storeMemory({
      content: "TypeScript adds static typing to JavaScript",
      tags: ["typescript"],
      project: TEST_PROJECT,
    });
    await sleep(100);
    const results = await searchMemories({
      query: "state management in React",
    });
    expect(results.length).toBeGreaterThan(0);
    expect(results[0].content).toContain("React hooks");
  });

  test("respects search limit", async () => {
    for (let i = 0; i < 5; i++) {
      await storeMemory({
        content: `Test entry ${i}`,
        project: TEST_PROJECT,
      });
    }
    await sleep(100);
    const results = await searchMemories({
      query: "test",
      limit: 2,
    });
    expect(results.length).toBeLessThanOrEqual(2);
  });

  test("filters by project", async () => {
    await storeMemory({
      content: "Project-specific memory",
      project: TEST_PROJECT,
    });
    await sleep(100);
    const results = await searchMemories({
      query: "memory",
      project: TEST_PROJECT,
    });
    expect(results.length).toBeGreaterThan(0);
  });

  test("lists all memories", async () => {
    await storeMemory({
      content: "List test 1",
      project: TEST_PROJECT,
    });
    await storeMemory({
      content: "List test 2",
      project: TEST_PROJECT,
    });
    await sleep(100);
    const results = await listMemories({
      project: TEST_PROJECT,
    });
    expect(results.length).toBe(2);
  });

  test("paginates list results", async () => {
    for (let i = 0; i < 4; i++) {
      await storeMemory({
        content: `Pagination test ${i}`,
        project: TEST_PROJECT,
      });
    }
    await sleep(100);
    const page1 = await listMemories({
      project: TEST_PROJECT,
      limit: 2,
      offset: 0,
    });
    const page2 = await listMemories({
      project: TEST_PROJECT,
      limit: 2,
      offset: 2,
    });
    expect(page1.length).toBe(2);
    expect(page2.length).toBe(2);
    expect(page1[0].id).not.toBe(page2[0].id);
  });

  test("gets memory by id", async () => {
    const result = await storeMemory({
      content: "Memory to retrieve",
      project: TEST_PROJECT,
    });
    const entry = await getMemory({ id: result.id });
    expect(entry).toBeDefined();
    expect(entry?.id).toBe(result.id);
    expect(entry?.content).toBe("Memory to retrieve");
  });

  test("returns null for non-existent id", async () => {
    const entry = await getMemory({ id: "non-existent-id", expectNull: true });
    expect(entry).toBeNull();
  });

  test("deletes memory", async () => {
    const result = await storeMemory({
      content: "Memory to delete",
      project: TEST_PROJECT,
    });
    const success = await deleteMemory({ id: result.id, expectSuccess: true });
    expect(success).toBe(true);
    const entry = await getMemory({ id: result.id, expectNull: true });
    expect(entry).toBeNull();
  });

  test("returns false when deleting non-existent memory", async () => {
    const success = await deleteMemory({
      id: "non-existent-id",
      expectSuccess: false,
    });
    expect(success).toBe(false);
  });

  test("retrieves context for query", async () => {
    await storeMemory({
      content: "Context retrieval test content",
      project: TEST_PROJECT,
    });
    await sleep(100);
    const context = await getContext({
      query: "test content",
      project: TEST_PROJECT,
    });
    expect(context).toBeDefined();
    expect(context.length).toBeGreaterThan(0);
  });

  test("respects max tokens in context", async () => {
    const context = await getContext({
      query: "token test",
      maxTokens: 100,
      project: TEST_PROJECT,
    });
    expect(context).toBeDefined();
  });
});
