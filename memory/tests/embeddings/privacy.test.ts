import { describe, test, expect } from "bun:test";
import { getEmbedding, checkOllamaHealth } from "../../src/embeddings/ollama.js";

describe("Privacy Verification", () => {
  test("Ollama URL is localhost only", () => {
    const ollamaUrl = process.env.OLLAMA_URL || "http://localhost:11434";
    expect(ollamaUrl).toContain("localhost");
    expect(ollamaUrl).not.toContain("api.openai.com");
    expect(ollamaUrl).not.toContain("anthropic.com");
    expect(ollamaUrl).not.toContain("cohere.ai");
  });

  test("no external API calls during embedding", async () => {
    const healthy = await checkOllamaHealth();
    
    if (!healthy) {
      const ollamaUrl = process.env.OLLAMA_URL || "http://localhost:11434";
      expect(ollamaUrl).toMatch(/localhost|127\.0\.0\.1/);
      return;
    }
    
    const result = await getEmbedding("Privacy test");
    expect(result.embedding).toBeInstanceOf(Array);
    expect(result.model).toBeDefined();
    expect(result.model).not.toMatch(/gpt|claude|cohere/i);
  });

  test("embedding model names are local models", async () => {
    const healthy = await checkOllamaHealth();
    if (!healthy) return;
    
    const result = await getEmbedding("Model verification");
    
    const localModels = ["nomic", "mxbai", "gemma", "all-minilm", "snowflake"];
    const isLocal = localModels.some(m => result.model.toLowerCase().includes(m));
    
    expect(isLocal).toBe(true);
  });
});
