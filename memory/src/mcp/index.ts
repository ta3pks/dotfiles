#!/usr/bin/env bun
import { runMcpServer } from "./server.js";

runMcpServer().catch(console.error);
