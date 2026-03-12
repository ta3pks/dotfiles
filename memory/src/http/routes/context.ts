import { Hono } from "hono";
import { MemoryService } from "../../core/service.js";

const context = new Hono();

context.get("/", async (c) => {
  try {
    const query = c.req.query("q");
    if (!query) {
      return c.json({ success: false, error: "Query parameter q required" }, 400);
    }
    const { maxTokens, project } = c.req.query();
    const service = new MemoryService();
    await service.init();
    const result = await service.getContext(query, {
      maxTokens: maxTokens ? +maxTokens : undefined,
      project,
    });
    return c.json({ success: true, data: result });
  } catch (err) {
    return c.json({ success: false, error: err.message }, 500);
  }
});

export { context };
