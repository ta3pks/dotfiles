import { describe, expect, mock, from "bun:test";
import app from "../../src/http/server.js";

// Mock MemoryService
const mockService = {
  init: mock(() => {}),
  store: mock(() => ({ id: "test-id", content: "Test" })),
  search: mock(() => [{ id: "test-id", content: "Test", score: 0.9 }]),
  get: mock(() => ({ id: "test-id", content: "Test" })),
  list: mock(() => []),
  delete: mock(() => true),
  getContext: mock(() => "Test context"),
  getTags: mock(() => ["tag1", "tag2"]),
  getProjects: mock(() => ["project1", "project2"]),
};

// Mock the module imports
mock.module("../../src/core/service.js", () => ({
  MemoryService: mock(() => mockService),
}));

describe("HTTP API", () => {
  describe("GET /health", () => {
    it("should return ok status", async () => {
      const res = await app.request("GET", "/health");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.status).toBe("ok");
      expect(body.timestamp).toBeDefined();
    });
  });

  describe("POST /memories", () => {
    it("should create a new memory", async () => {
      const res = await app.request("POST", "/memories")
        .json({
          content: "Test memory content",
          tags: ["test"],
          project: "test-project",
        });
      expect(res.status).toBe(201);
      const body = await res.json();
      expect(body.success).toBe(true);
      expect(body.data).toHaveProperty("id");
      expect(body.data.content).toBe("Test memory content");
    });

    it("should require content field", async () => {
      const res = await app.request("POST", "/memories")
        .json({
          tags: ["test"],
        });
      expect(res.status).toBe(500);
    });
  });

  describe("GET /memories", () => {
    it("should list memories", async () => {
      mockService.list.mockReturnValue([{ id: "1", content: "Memory 1" }]);

      const res = await app.request("GET", "/memories");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.success).toBe(true);
      expect(Array.isArray(body.data)).toBe(true);
    });

    it("should filter by project", async () => {
      mockService.list.mockReturnValue([{ id: "1", project: "project1" }]);

      const res = await app.request("GET", "/memories?project=project1");
      expect(res.status).toBe(200);
    });
  });

  describe("GET /memories/search", () => {
    it("should search memories", async () => {
      mockService.search.mockReturnValue([
        { id: "1", content: "Found memory", score: 0.95 },
      ]);

      const res = await app.request("GET", "/memories/search?q=test");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.success).toBe(true);
    });

    it("should require query parameter", async () => {
      const res = await app.request("GET", "/memories/search");
      expect(res.status).toBe(400);
    });
  });

  describe("GET /memories/:id", () => {
    it("should get a specific memory", async () => {
      mockService.get.mockReturnValue({ id: "test-id", content: "Test" });

      const res = await app.request("GET", "/memories/test-id");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.success).toBe(true);
      expect(body.data.id).toBe("test-id");
    });

    it("should return 404 for non-existent memory", async () => {
      mockService.get.mockReturnValue(null);

      const res = await app.request("GET", "/memories/nonexistent");
      expect(res.status).toBe(404);
    });
  });

  describe("DELETE /memories/:id", () => {
    it("should delete a memory", async () => {
      mockService.delete.mockReturnValue(true);

      const res = await app.request("DELETE", "/memories/test-id");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.success).toBe(true);
      expect(body.data.deleted).toBe(true);
    });

    it("should return 404 for non-existent memory", async () => {
      mockService.delete.mockReturnValue(false);

      const res = await app.request("DELETE", "/memories/nonexistent");
      expect(res.status).toBe(404);
    });
  });

  describe("GET /context", () => {
    it("should get formatted context", async () => {
      mockService.getContext.mockReturnValue("Formatted context string");

      const res = await app.request("GET", "/context?q=test");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.success).toBe(true);
      expect(body.data).toBe("Formatted context string");
    });

    it("should require query parameter", async () => {
      const res = await app.request("GET", "/context");
      expect(res.status).toBe(400);
    });
  });

  describe("GET /tags", () => {
    it("should list all unique tags", async () => {
      mockService.getTags.mockReturnValue(["tag1", "tag2", "tag3"]);

      const res = await app.request("GET", "/tags");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.success).toBe(true);
      expect(body.data).toEqual(["tag1", "tag2", "tag3"]);
    });
  });

  describe("GET /projects", () => {
    it("should list all unique projects", async () => {
      mockService.getProjects.mockReturnValue(["project1", "project2"]);

      const res = await app.request("GET", "/projects");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.success).toBe(true);
      expect(body.data).toEqual(["project1", "project2"]);
    });
  });

  describe("CORS", () => {
    it("should have CORS headers", async () => {
      const res = await app.request("GET", "/health", {
        headers: { Origin: "http://localhost:3000" },
      });
      expect(res.headers.get("Access-Control-Allow-Origin")).toBeDefined();
    });
  });
});
