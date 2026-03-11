import { describe, test, expect, beforeAll } from "bun:test";
import { getEmbedding, checkOllamaHealth } from "../../src/embeddings/ollama.js";
import { getDimensions, EMBEDDING_MODELS, type ModelName } from "../../src/embeddings/models.js";

describe("Multi-Model Support", () => {
  let ollamaHealthy = false;
  
  beforeAll(async () => {
    ollamaHealthy = await checkOllamaHealth();
  });

  test("supports nomic-embed-text model", async () => {
    if (!ollamaHealthy) return;
    
    const result = await getEmbedding("Test with nomic", "nomic-embed-text");
    expect(result.embedding.length).toBe(768);
  });

  test("model dimensions are correct", () => {
    expect(getDimensions("nomic-embed-text")).toBe(768);
    expect(getDimensions("mxbai-embed-large")).toBe(1024);
    expect(getDimensions("embeddinggemma")).toBe(768);
  });

  test("all configured models have valid dimensions", () => {
    Object.entries(EMBEDDING_MODELS).forEach(([name, config]) => {
      expect(config.dimensions).toBeGreaterThan(0);
      expect(config.family).toBeDefined();
    });
  });

  test("handles model not available gracefully", async () => {
    if (!ollamaHealthy) return;
    
    try {
      await getEmbedding("Test", "nonexistent-model-xyz" as ModelName);
    } catch (error) {
      expect(error).toBeDefined();
    }
  });
});
