import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import { MemoryService } from "../../src/core/service.js";
import { handleCommand } from "../../src/stdio/commands.js";
import type { StdioRequest, StdioResponse } from "../../src/stdio/types.js";
import { rm, mkdir } from "node:fs/promises";
import { join } from "path";

const TEST_DATA_PATH = join(import.meta.dirname, "../../test-data-stdio");

let service: MemoryService;

beforeEach(async () => {
  await rm(TEST_DATA_PATH).catch(() => {});
  await mkdir(TEST_DATA_PATH, { recursive: true });
  service = new MemoryService();
  await service.init(TEST_DATA_PATH);
});

afterEach(async () => {
  await rm(TEST_DATA_PATH).catch(() => {});
});

describe("Stdio Commands", () => {
  describe("store command", () => {
    test("stores memory with content", async () => {
      const request: StdioRequest = {
        command: "store",
        content: "Test memory content",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(true);
      expect(response.data?.id).toBeDefined();
    });

    test("stores memory with tags and project", async () => {
      const request: StdioRequest = {
        command: "store",
        content: "Tagged memory",
        tags: ["test", "example"],
        project: "stdio-test",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(true);
      expect(response.data?.id).toBeDefined();
    });

    test("rejects empty content", async () => {
      const request: StdioRequest = {
        command: "store",
        content: "",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(false);
      expect(response.code).toBe("VALIDATION_ERROR");
    });
  });

  describe("search command", () => {
    test("returns relevant results", async () => {
      // Store test data
      await handleCommand(service, {
        command: "store",
        content: "React hooks allow state management in functional components",
        tags: ["react"],
      });
      await handleCommand(service, {
        command: "store",
        content: "TypeScript adds static typing to JavaScript",
        tags: ["typescript"],
      });

      const request: StdioRequest = {
        command: "search",
        query: "state management in React",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(true);
      expect(response.data?.length).toBeGreaterThan(0);
    });

    test("respects limit parameter", async () => {
      // Store multiple entries
      for (let i = 0; i < 5; i++) {
        await handleCommand(service, {
          command: "store",
          content: `Test entry ${i}`,
        });
      }

      const request: StdioRequest = {
        command: "search",
        query: "test",
        limit: 2,
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(true);
      expect(response.data?.length).toBeLessThanOrEqual(2);
    });

    test("rejects empty query", async () => {
      const request: StdioRequest = {
        command: "search",
        query: "",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(false);
      expect(response.code).toBe("VALIDATION_ERROR");
    });
  });

  describe("get command", () => {
    test("returns memory by id", async () => {
      const storeResponse = await handleCommand(service, {
        command: "store",
        content: "Memory to retrieve",
      });
      const id = storeResponse.data?.id;

      const request: StdioRequest = {
        command: "get",
        id,
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(true);
      expect(response.data?.content).toBe("Memory to retrieve");
    });

    test("returns error for non-existent id", async () => {
      const request: StdioRequest = {
        command: "get",
        id: "non-existent-id",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(false);
      expect(response.code).toBe("NOT_FOUND");
    });
  });

  describe("list command", () => {
    test("lists all memories", async () => {
      await handleCommand(service, {
        command: "store",
        content: "List test 1",
        project: "list-test",
      });
      await handleCommand(service, {
        command: "store",
        content: "List test 2",
        project: "list-test",
      });

      const request: StdioRequest = {
        command: "list",
        project: "list-test",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(true);
      expect(response.data?.length).toBe(2);
    });

    test("supports pagination", async () => {
      for (let i = 0; i < 5; i++) {
        await handleCommand(service, {
          command: "store",
          content: `Pagination test ${i}`,
          project: "pagination-test",
        });
      }

      const request: StdioRequest = {
        command: "list",
        project: "pagination-test",
        limit: 2,
        offset: 0,
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(true);
      expect(response.data?.length).toBe(2);
    });
  });

  describe("delete command", () => {
    test("deletes existing memory", async () => {
      const storeResponse = await handleCommand(service, {
        command: "store",
        content: "Memory to delete",
      });
      const id = storeResponse.data?.id;

      const request: StdioRequest = {
        command: "delete",
        id,
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(true);
      expect(response.data?.deleted).toBe(true);

      // Verify it's gone
      const getResponse = await handleCommand(service, {
        command: "get",
        id,
      });
      expect(getResponse.success).toBe(false);
    });

    test("returns error for non-existent id", async () => {
      const request: StdioRequest = {
        command: "delete",
        id: "non-existent-id",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(false);
      expect(response.code).toBe("NOT_FOUND");
    });
  });

  describe("context command", () => {
    test("returns context for query", async () => {
      await handleCommand(service, {
        command: "store",
        content: "Context retrieval test content",
        project: "context-test",
      });

      const request: StdioRequest = {
        command: "context",
        query: "test content",
        project: "context-test",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(true);
      expect(response.data).toBeDefined();
    });

    test("rejects empty query", async () => {
      const request: StdioRequest = {
        command: "context",
        query: "",
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(false);
      expect(response.code).toBe("VALIDATION_ERROR");
    });
  });

  describe("unknown command", () => {
    test("returns error for unknown command", async () => {
      const request: StdioRequest = {
        command: "unknown" as any,
      };

      const response = await handleCommand(service, request);

      expect(response.success).toBe(false);
      expect(response.code).toBe("UNKNOWN_COMMAND");
    });
  });
});
