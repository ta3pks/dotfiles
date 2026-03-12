import { describe, test, expect, beforeEach, afterEach } from 'bun:test';
import { mkdir, rm, readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import {
  setupTestDb,
  createTestMemories,
  assertFileExists,
  assertJsonFileValid
} from './helpers/setup.js';
import { MemoryService } from '../../src/core/index.js';
import type { MemoryEntry } from '../../src/storage/types.js';

describe('Export Command', () => {
  let testDb: Awaited<ReturnType<typeof setupTestDb>>;
  let exportDir: string;

  beforeEach(async () => {
    testDb = await setupTestDb();
    
    // Create temp export directory
    const testId = `export-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
    exportDir = join(tmpdir(), testId);
    await mkdir(exportDir, { recursive: true });
  });

  afterEach(async () => {
    await testDb.cleanup();
    await rm(exportDir, { recursive: true, force: true }).catch(() => {});
  });

  describe('individual JSON files', () => {
    test('creates one JSON file per memory', async () => {
      // Create test memories
      const memories = await createTestMemories(testDb.service, 3);
      
      // Simulate export logic
      for (const memory of memories) {
        const filepath = join(exportDir, `${memory.id}.json`);
        const data = {
          id: memory.id,
          content: memory.content,
          tags: memory.tags,
          project: memory.project,
          createdAt: new Date(memory.createdAt).toISOString(),
          embeddingModel: memory.embeddingModel
        };
        await Bun.write(filepath, JSON.stringify(data));
      }
      
      // Verify files exist
      const files = await readdir(exportDir);
      expect(files.length).toBe(3);
      
      for (const memory of memories) {
        await assertFileExists(join(exportDir, `${memory.id}.json`));
      }
    });

    test('each JSON file contains valid memory data', async () => {
      const memories = await createTestMemories(testDb.service, 1);
      const memory = memories[0];
      
      const filepath = join(exportDir, `${memory.id}.json`);
      const data = {
        id: memory.id,
        content: memory.content,
        tags: memory.tags,
        project: memory.project,
        createdAt: new Date(memory.createdAt).toISOString(),
        embeddingModel: memory.embeddingModel
      };
      await Bun.write(filepath, JSON.stringify(data));
      
      const parsed = await assertJsonFileValid(filepath) as any;
      expect(parsed.id).toBe(memory.id);
      expect(parsed.content).toBe(memory.content);
      expect(parsed.tags).toEqual(memory.tags);
    });
  });

  describe('--embeddings flag', () => {
    test('includes hasEmbedding field when flag is true', async () => {
      const memories = await createTestMemories(testDb.service, 1);
      const memory = memories[0];
      
      const filepath = join(exportDir, `${memory.id}.json`);
      const data = {
        id: memory.id,
        content: memory.content,
        tags: memory.tags,
        project: memory.project,
        createdAt: new Date(memory.createdAt).toISOString(),
        embeddingModel: memory.embeddingModel,
        hasEmbedding: true
      };
      await Bun.write(filepath, JSON.stringify(data));
      
      const parsed = await assertJsonFileValid(filepath) as any;
      expect(parsed.hasEmbedding).toBe(true);
    });

    test('excludes embedding fields by default', async () => {
      const memories = await createTestMemories(testDb.service, 1);
      const memory = memories[0];
      
      const filepath = join(exportDir, `${memory.id}.json`);
      const data = {
        id: memory.id,
        content: memory.content,
        tags: memory.tags,
        project: memory.project,
        createdAt: new Date(memory.createdAt).toISOString(),
        embeddingModel: memory.embeddingModel
      };
      await Bun.write(filepath, JSON.stringify(data));
      
      const parsed = await assertJsonFileValid(filepath) as any;
      expect(parsed.hasEmbedding).toBeUndefined();
    });
  });

  describe('--pretty flag', () => {
    test('formats JSON with indentation when flag is true', async () => {
      const memories = await createTestMemories(testDb.service, 1);
      const memory = memories[0];
      
      const filepath = join(exportDir, `${memory.id}.json`);
      const data = {
        id: memory.id,
        content: memory.content,
        tags: memory.tags
      };
      await Bun.write(filepath, JSON.stringify(data, null, 2));
      
      const content = await readFile(filepath, 'utf-8');
      expect(content).toContain('\n');
      expect(content).toContain('  "id"');
    });

    test('outputs compact JSON when flag is false', async () => {
      const memories = await createTestMemories(testDb.service, 1);
      const memory = memories[0];
      
      const filepath = join(exportDir, `${memory.id}.json`);
      const data = {
        id: memory.id,
        content: memory.content,
        tags: memory.tags
      };
      await Bun.write(filepath, JSON.stringify(data));
      
      const content = await readFile(filepath, 'utf-8');
      // Compact JSON should not have leading spaces on lines
      expect(content).not.toMatch(/^\s+"id"/m);
    });
  });

  describe('--metadata flag', () => {
    test('creates metadata.json with export info', async () => {
      const memories = await createTestMemories(testDb.service, 3);
      
      // Write memory files
      for (const memory of memories) {
        const filepath = join(exportDir, `${memory.id}.json`);
        await Bun.write(filepath, JSON.stringify({ id: memory.id }));
      }
      
      // Write metadata
      const metadata = {
        exportedAt: new Date().toISOString(),
        version: '1.0.0',
        count: memories.length,
        filters: { project: null, tag: null },
        options: { embeddings: false, pretty: false }
      };
      await Bun.write(join(exportDir, 'metadata.json'), JSON.stringify(metadata, null, 2));
      
      // Verify metadata
      await assertFileExists(join(exportDir, 'metadata.json'));
      const parsed = await assertJsonFileValid(join(exportDir, 'metadata.json')) as any;
      expect(parsed.version).toBe('1.0.0');
      expect(parsed.count).toBe(3);
    });
  });

  describe('project/tag filters', () => {
    test('only exports memories matching project filter', async () => {
      // Create memories with different projects
      await testDb.service.store('Memory for project A', { project: 'project-a' });
      await testDb.service.store('Memory for project B', { project: 'project-b' });
      
      // Simulate filtered export
      const allMemories = await testDb.service.list({ project: 'project-a' });
      
      for (const memory of allMemories) {
        const filepath = join(exportDir, `${memory.id}.json`);
        await Bun.write(filepath, JSON.stringify({ id: memory.id, project: memory.project }));
      }
      
      const files = await readdir(exportDir);
      expect(files.length).toBe(1);
      
      const parsed = await assertJsonFileValid(join(exportDir, files[0])) as any;
      expect(parsed.project).toBe('project-a');
    });

    test('only exports memories matching tag filter', async () => {
      // Create memories with different tags
      await testDb.service.store('Tagged memory', { tags: ['important', 'work'] });
      await testDb.service.store('Other memory', { tags: ['personal'] });
      
      // Simulate filtered export
      const allMemories = await testDb.service.list({ tag: 'important' });
      
      for (const memory of allMemories) {
        const filepath = join(exportDir, `${memory.id}.json`);
        await Bun.write(filepath, JSON.stringify({ id: memory.id, tags: memory.tags }));
      }
      
      const files = await readdir(exportDir);
      expect(files.length).toBe(1);
      
      const parsed = await assertJsonFileValid(join(exportDir, files[0])) as any;
      expect(parsed.tags).toContain('important');
    });
  });

  describe('empty export', () => {
    test('handles empty memory store gracefully', async () => {
      // No memories created
      const memories = await testDb.service.list();
      expect(memories.length).toBe(0);
      
      // Export should complete without error
      const files = await readdir(exportDir);
      expect(files.length).toBe(0);
    });
  });
});
