import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import { MemoryService } from "../../src/core/index.js";
import { rm, mkdir } from "node:fs/promises";
import { join } from "path";

let currentTestPath: string;
let service: MemoryService;

beforeEach(async () => {
  currentTestPath = join(import.meta.dirname, `../../test-data-${Date.now()}-${Math.random().toString(36).slice(2)}`);
  await mkdir(currentTestPath, { recursive: true });
  service = new MemoryService();
  await service.init(currentTestPath);
});

afterEach(async () => {
  if (currentTestPath) {
    await rm(currentTestPath, { recursive: true, force: true }).catch(() => {});
  }
});

describe("MemoryService", () => {
  describe("store", () => {
    test("creates memory with auto-embedding", async () => {
      const entry = await service.store("React hooks are functions that let you use state in functional components", {
        tags: ["react", "hooks"],
        project: "test-project",
        type: "pattern",
      });

      expect(entry.id).toBeDefined();
      expect(entry.content).toBe("React hooks are functions that let you use state in functional components");
      expect(entry.tags).toEqual(["react", "hooks"]);
      expect(entry.project).toBe("test-project");
      expect(entry.embeddingModel).toBeDefined();
      expect(entry.createdAt).toBeGreaterThan(0);
    });

    test("stores with default options", async () => {
      const entry = await service.store("Simple memory content");

      
      expect(entry.tags).toEqual([]);
      expect(entry.project).toBeNull();
    });
  });

  describe("search", () => {
    test("returns relevant results", async () => {
      await service.store("React hooks are functions that let you use state in functional components", {
        tags: ["react"],
      });
      await service.store("TypeScript provides type safety for JavaScript applications", {
        tags: ["typescript"],
      });

      const results = await service.search("how to use state in React");
      
      expect(results.length).toBeGreaterThan(0);
      const reactResult = results.find(r => r.tags.includes("react"));
      expect(reactResult).toBeDefined();
      expect(reactResult?.score).toBeGreaterThan(0);
    });

    test("filters by project", async () => {
      await service.store("Project A note", { project: "project-a" });
      await service.store("Project B note", { project: "project-b" });

      
      const results = await service.search("note", { project: "project-a" });
      expect(results.length).toBeGreaterThanOrEqual(1);
      results.forEach(r => expect(r.project).toBe("project-a"));
    });

    test("filters by tags", async () => {
      await service.store("React component", { tags: ["react", "ui"] });
      await service.store("Backend API", { tags: ["node", "api"] });

      
      const results = await service.search("code", { tags: ["react"] });
      expect(results.every(r => r.tags.includes("react"))).toBe(true);
    });
  });

  describe("get", () => {
    test("retrieves memory by ID", async () => {
      const stored = await service.store("Unique content for retrieval test");
      const retrieved = await service.get(stored.id);
      
      expect(retrieved).not.toBeNull();
      expect(retrieved?.id).toBe(stored.id);
      expect(retrieved?.content).toBe("Unique content for retrieval test");
    });

    test("returns null for non-existent ID", async () => {
      const result = await service.get("non-existent-id-12345");
      expect(result).toBeNull();
    });
  });

  describe("list", () => {
    test("lists all memories", async () => {
      await service.store("Memory 1");
      await service.store("Memory 2");
      await service.store("Memory 3");
      
      const results = await service.list();
      expect(results.length).toBeGreaterThanOrEqual(3);
    });

    test("filters by project", async () => {
      await service.store("Project A item 1", { project: "project-a" });
      await service.store("Project A item 2", { project: "project-a" });
      await service.store("Project B item", { project: "project-b" });
      
      const results = await service.list({ project: "project-a" });
      expect(results.length).toBe(2);
      results.forEach(r => expect(r.project).toBe("project-a"));
    });

    test("filters by tag", async () => {
      await service.store("Tagged item alpha", { tags: ["alpha", "test"] });
      await service.store("Tagged item beta", { tags: ["beta", "test"] });
      await service.store("Untagged item", { tags: [] });
      
      const results = await service.list({ tag: "alpha" });
      expect(results.length).toBe(1);
      expect(results[0].tags).toContain("alpha");
    });

    test("supports pagination", async () => {
      for (let i = 0; i < 10; i++) {
        await service.store(`Item ${i}`);
      }
      
      const page1 = await service.list({ limit: 5, offset: 0 });
      const page2 = await service.list({ limit: 5, offset: 5 });
      
      expect(page1.length).toBe(5);
      expect(page2.length).toBe(5);
    });
  });

  describe("delete", () => {
    test("removes memory from both stores", async () => {
      const stored = await service.store("Memory to be deleted");
      const retrievedBefore = await service.get(stored.id);
      expect(retrievedBefore).not.toBeNull();
      
      const deleted = await service.delete(stored.id);
      expect(deleted).toBe(true);
      
      const retrievedAfter = await service.get(stored.id);
      expect(retrievedAfter).toBeNull();
    });

    test("returns false for non-existent ID", async () => {
      const result = await service.delete("non-existent-id-xyz");
      expect(result).toBe(false);
    });
  });

  describe("getContext", () => {
    test("formats relevant memories as context", async () => {
      await service.store("React state management patterns include useState and useReducer hooks", {
        tags: ["react"],
        project: "frontend",
      });
      await service.store("Node.js backend best practices include error handling", {
        tags: ["node"],
        project: "backend",
      });
      
      const context = await service.getContext("React hooks state");
      expect(context).toContain("React");
      expect(context).toContain("Memory:");
    });

    test("respects maxTokens limit", async () => {
      for (let i = 0; i < 5; i++) {
        await service.store(`Long content item ${i} with many words to describe a concept in detail for context building`, {
          project: "test",
        });
      }
      
      const shortContext = await service.getContext("content", { maxTokens: 50 });
      const tokens = shortContext.split(/\s+/).length;
      expect(tokens).toBeLessThanOrEqual(50);
    });

    test("filters by project", async () => {
      await service.store("Project X content", { project: "project-x" });
      await service.store("Project Y content", { project: "project-y" });
      
      const context = await service.getContext("content", { project: "project-x" });
      expect(context).toContain("project-x");
      expect(context).not.toContain("project-y");
    });
  });

  describe("getTags", () => {
    test("returns all unique tags", async () => {
      await service.store("Item with react tag", { tags: ["react", "ui"] });
      await service.store("Item with node tag", { tags: ["node", "backend"] });
      await service.store("Item with common tag", { tags: ["react", "common"] });
      
      const tags = await service.getTags();
      expect(tags).toContain("react");
      expect(tags).toContain("ui");
      expect(tags).toContain("node");
      expect(tags).toContain("backend");
      expect(tags).toContain("common");
    });

    test("returns sorted tags", async () => {
      await service.store("Z tag item", { tags: ["z-tag"] });
      await service.store("A tag item", { tags: ["a-tag"] });
      
      const tags = await service.getTags();
      const zIndex = tags.indexOf("z-tag");
      const aIndex = tags.indexOf("a-tag");
      expect(aIndex).toBeLessThan(zIndex);
    });
  });

  describe("getProjects", () => {
    test("returns all unique projects", async () => {
      await service.store("Project A", { project: "project-a" });
      await service.store("Project B", { project: "project-b" });
      await service.store("Project A duplicate", { project: "project-a" });
      
      const projects = await service.getProjects();
      expect(projects).toContain("project-a");
      expect(projects).toContain("project-b");
      expect(projects.filter(p => p === "project-a").length).toBe(1);
    });

    test("returns sorted projects", async () => {
      await service.store("Z project", { project: "z-project" });
      await service.store("A project", { project: "a-project" });
      
      const projects = await service.getProjects();
      const zIndex = projects.indexOf("z-project");
      const aIndex = projects.indexOf("a-project");
      expect(aIndex).toBeLessThan(zIndex);
    });
  });
});
