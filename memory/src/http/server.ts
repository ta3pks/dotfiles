import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { MemoryService } from "../core/service.js";

import { memoriesRoutes } from "./routes/memories.js";
import { contextRoutes } from "./routes/context.js";
import { metaRoutes } from "./routes/meta.js";

const app = new Hono();

app.use("*", cors());
app.use("*", logger());

app.route("/memories", memoriesRoutes);
app.route("/context", contextRoutes);
app.route("/", metaRoutes);

export function startServer(port: number = 3456) {
  console.log(`Memory HTTP server starting on port ${port}`);
  return Bun.serve({
    port,
    fetch: app.fetch,
  });
}

export { app };
