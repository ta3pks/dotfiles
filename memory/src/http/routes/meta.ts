import { Hono } from "hono";
import { MemoryService } from "../../core/service.js";

const meta = new Hono();

meta.get("/tags", async (c) => {
  try {
    const service = new MemoryService();
    await service.init();
    const tags = await service.getTags();
    return c.json({ success: true, data: tags });
  } catch (err) {
    return c.json({ success: false, error: err.message }, 500);
  }
});

meta.get("/projects", async (c) => {
  try {
    const service = new MemoryService();
    await service.init();
    const projects = await service.getProjects();
    return c.json({ success: true, data: projects });
  } catch (err) {
    return c.json({ success: false, error: err.message }, 500);
  }
});

meta.get("/health", (c) => {
  return c.json({ status: "ok", timestamp: Date.now() });
});

export { meta as metaRoutes };
