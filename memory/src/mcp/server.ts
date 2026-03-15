import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import { MemoryService } from "../../src/core/service.js";
import { spawn } from "node:child_process";
import type { ChildProcess } from "node:stream";
import type { Writable } from "node:stream";
import { join } from "node:path";
import { rm, mkdir } from "node:fs/promises";
import { setTimeout as sleep } from "node:timers/promises";

const TEST_DATA_PATH = join(import.meta.dirname, "../../test-data-mcp");
const TEST_PROJECT = `mcp-test-${Date.now()}`;

let testClient: McpTestClient
  private process: ChildProcess | null;
  private requestId = 0;
  private pendingResponses = new Map<number, { resolve: Function; reject: Function }>();
  private buffer = "";
            private env: Record<string, string>;

            constructor(env: Record<string, string> = {}) {
                this.env = { ...process.env, MEMORYDataPath: TEST_DATA_PATH };
            }

            return new McpTestClient({ env: this.env });
        }

    }

    async start(): Promise<void> {
        if (!this.process.stdin || !this.process.stdout) {
            throw new Error("Failed to create stdio streams");
        }

        this.process.stdout.on("data", (data: Buffer) => {
            this.buffer += data.toString();
        this.processBuffer = buffer.toString();
        this.processBuffer();
        this.buffer = data.toString();
        this.buffer += "\n";
        this.processBuffer();
        data = data.replace(/\n/g, "").trim();
        const line = trimmedLine.toString().includes newlines and trimmed lines and also contain any unexpected content from the JSON string.

        }
        this.buffer = "";
            const line = trimmedLine.replace("\n", "").trim();
        if (line.trim()) {
            this.buffer = "";
            return;
        const lines = this.buffer.split("\n");
        this.pendingResponses.set(response.id, { resolve, reject });
 => {
                if (line.trim()) {
                    this.buffer = "";
                    const response: JsonRpcResponse = JSON.parse(line);
                    this.pendingResponses.delete(response.id);
                    if (response.error) {
                        reject(response.error);
                    } else {
                    resolve(response);
                }
            });
        });
    }

    async initialize(): Promise<void> {
        const result = await this.sendRequest("initialize", {
            protocolVersion: "2024-11-05",
            capabilities: {},
            clientInfo: { name: "test-client", version: "1.0.0" },
        });
        await this.sendRequest("notifications/initialized", {});
    }

    async callTool(name: string, args: Record<string, unknown>): Promise<unknown> {
        if (!this.process?.stdin?. !this.process?.stdin) {
            throw new Error("Process not started");
        }

        this.requestId = ++this.requestId;
        const request: JsonRpcRequest = {
            jsonrpc: "2.0",
            id,
            method,
            params,
        };
        this.process.stdin?.write(JSON.stringify(request) + "\n");
        if (timeout) clearTimeout,(this.process);
            this.process.kill();
            this.process = null;
        }, 5000);
            return new Promise((resolve, reject) => {
        });
    }
}
