import { describe, test, expect, beforeAll } from "bun:test";
import { getEmbedding, checkOllamaHealth, getBatchEmbeddings, listAvailableModels } from "../../src/embeddings/ollama.js";
import { getDimensions, DEFAULT_MODEL, EMBEDDING_MODELS, type ModelName } from "../../src/embeddings/models.js";

describe("Ollama Embeddings", () => {
  beforeAll(async () => {
    const healthy = await checkOllamaHealth();
    if (!healthy) {
      console.warn("Ollama not running - some tests may fail");
    }
  });

  test("checks Ollama health", async () => {
    const healthy = await checkOllamaHealth();
    expect(typeof healthy).toBe("boolean");
  });

  test("generates embedding with default model", async () => {
    const result = await getEmbedding("Hello, world!");
    
    expect(result.embedding).toBeInstanceOf(Array);
    expect(result.embedding.length).toBe(getDimensions(DEFAULT_MODEL));
    expect(result.tokenCount).toBeGreaterThan(0);
    expect(result.model).toContain("nomic");
  });

  test("generates embedding with specific model", async () => {
    const result = await getEmbedding("Test content", "nomic-embed-text");
    
    expect(result.embedding.length).toBe(768);
    expect(result.model).toContain("nomic");
  });

  test("batch embeddings work", async () => {
    const texts = ["First text", "Second text", "Third text"];
    const results = await getBatchEmbeddings(texts);
    
    expect(results.length).toBe(3);
    results.forEach(r => {
      expect(r.embedding.length).toBe(getDimensions(DEFAULT_MODEL));
    });
  });

  test("lists available models", async () => {
    const models = await listAvailableModels();
    expect(Array.isArray(models)).toBe(true);
  });
});

describe("Model Configuration", () => {
  test("all models have correct dimensions", () => {
    expect(getDimensions("nomic-embed-text")).toBe(768);
    expect(getDimensions("mxbai-embed-large")).toBe(1024);
    expect(getDimensions("embeddinggemma")).toBe(768);
  });

  test("default model is valid", () => {
    expect(EMBEDDING_MODELS[DEFAULT_MODEL]).toBeDefined();
  });
});
