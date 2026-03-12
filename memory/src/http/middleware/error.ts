import type { Context } from "hono";

export async function errorHandler(error: Error, c: Context) {
  console.error("HTTP Error:", error);
  
  const status = (error as any).status || 500;
  const code = (error as any).code || "INTERNAL_ERROR";
  
  return c.json(
    {
      success: false,
      error: error.message || "Internal server error",
      code,
    },
    status
  );
}
