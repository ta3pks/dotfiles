import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import { initVectorStore, addVector, searchSimilar, deleteVector, closeVectorStore } from "../../src/storage/lancedb.js";
import { rm } from "fs/promises";
import { join } from "path";

const TEST_DB_PATH = join(import.meta.dir, "..", "fixtures", "test_vectors");

describe("LanceDB Storage", () => {
  beforeEach(async () => {
    await rm(TEST_DB_PATH, { recursive: true, force: true });
  });

  afterEach(async () => {
    await closeVectorStore();
  });

  test("initializes vector store", async () => {
    const db = await initVectorStore(TEST_DB_PATH);
    expect(db).toBeDefined();
  });

  test("adds and searches vectors", async () => {
    await initVectorStore(TEST_DB_PATH);
    
    await addVector({
      id: "test-001",
      vector: new Array(768).fill(0.1),
      content: "Test memory content"
    });
    
    const results = await searchSimilar(new Array(768).fill(0.1), 5);
    expect(results.length).toBeGreaterThan(0);
    expect(results[0].id).toBe("test-001");
  });

  test("deletes vectors", async () => {
    await initVectorStore(TEST_DB_PATH);
    
    await addVector({
      id: "test-002",
      vector: new Array(768).fill(0.2),
      content: "To be deleted"
    });
    
    await deleteVector("test-002");
    
    const results = await searchSimilar(new Array(768).fill(0.2), 10);
    expect(results.find(r => r.id === "test-002")).toBeUndefined();
  });
});
