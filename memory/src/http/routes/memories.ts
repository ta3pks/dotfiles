import { Hono } from "hono";
import { MemoryService } from "../../core/service.js";

const memories = new Hono();

memories.post("/", async (c) => {
  try {
    const body = await c.req.json();
    const service = new MemoryService();
    await service.init();
    const result = await service.store(body.content, {
      tags: body.tags,
      project: body.project,
    });
    return c.json({ success: true, data: result }, 201);
  } catch (err) {
    return c.json({ success: false, error: err.message }, 500);
  }
});

memories.get("/", async (c) => {
  try {
    const { project, tag, limit, offset } = c.req.query();
    const service = new MemoryService();
    await service.init();
    const results = await service.list({
      project,
      tag,
      limit: limit ? +limit : undefined,
      offset: offset ? +offset : undefined,
    });
    return c.json({ success: true, data: results });
  } catch (err) {
    return c.json({ success: false, error: err.message }, 500);
  }
});

memories.get("/search", async (c) => {
  try {
    const query = c.req.query("q");
    if (!query) {
      return c.json({ success: false, error: "Query parameter required" }, 400);
    }
    const { limit, project } = c.req.query();
    const service = new MemoryService();
    await service.init();
    const results = await service.search(query, {
      limit: limit ? +limit : undefined,
      project,
    });
    return c.json({ success: true, data: results });
  } catch (err) {
    return c.json({ success: false, error: err.message }, 500);
  }
});

memories.get("/:id", async (c) => {
  try {
    const id = c.req.param("id");
    const service = new MemoryService();
    await service.init();
    const result = await service.get(id);
    if (!result) {
      return c.json({ success: false, error: "Memory not found" }, 404);
    }
    return c.json({ success: true, data: result });
  } catch (err) {
    return c.json({ success: false, error: err.message }, 500);
  }
});

memories.delete("/:id", async (c) => {
  try {
    const id = c.req.param("id");
    const service = new MemoryService();
    await service.init();
    const deleted = await service.delete(id);
    if (!deleted) {
      return c.json({ success: false, error: "Memory not found" }, 404);
    }
    return c.json({ success: true, data: { deleted: true } });
  } catch (err) {
    return c.json({ success: false, error: err.message }, 500);
  }
});

export { memories as memoriesRoutes };
