#!/usr/bin/env bun
import * as readline from "readline";
import { MemoryService } from "../core/service.js";
import { handleCommand } from "./commands.js";
import type { StdioRequest, StdioResponse } from "./types.js";

// Shared service instance for all commands
const service = new MemoryService();

async function handleRequest(request: unknown): Promise<StdioResponse> {
  try {
    const parsed = typeof request === "string" ? JSON.parse(request) : request;
    return await handleCommand(service, parsed as StdioRequest);
  } catch (err) {
    return {
      success: false,
      error: err instanceof Error ? err.message : String(err),
      code: "INTERNAL_ERROR",
    };
  }
}

// Initialize service before processing
await service.init();

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false,
});

rl.on("line", async (line) => {
  const response = await handleRequest(line);
  console.log(JSON.stringify(response));
});
