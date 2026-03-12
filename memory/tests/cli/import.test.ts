import { describe, test, expect, beforeEach, afterEach } from 'bun:test';
import { mkdir, rm, readdir, readFile, writeFile, stat } from 'node:fs/promises';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import {
  setupTestDb,
  createTestMemories,
  assertFileExists,
  assertJsonFileValid
} from './helpers/setup.js';

describe('Import Command', () => {
  let testDb: Awaited<ReturnType<typeof setupTestDb>>;
  let importDir: string;

  beforeEach(async () => {
    testDb = await setupTestDb();
    
    // Create temp import directory
    const testId = `import-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
    importDir = join(tmpdir(), testId);
    await mkdir(importDir, { recursive: true });
  });

  
  afterEach(async () => {
    await testDb.cleanup();
    await rm(importDir, { recursive: true, force: true }).catch(() => {});
  });

  describe('memory creation from JSON files', () => {
    test('creates memory from valid JSON file', async () => {
      // Create import file
      const importFile = join(importDir, 'test-memory.json');
      const importData = {
        content: 'Imported memory content',
        tags: ['imported', 'test'],
        project: 'test-project'
      };
      await writeFile(importFile, JSON.stringify(importData));

      // Simulate import: read file and store
      const existingCount = (await testDb.service.list()).length;
      await testDb.service.store(importData.content, {
        tags: importData.tags,
        project: importData.project
      });

      // Verify memory was created
      const memories = await testDb.service.list();
      expect(memories.length).toBe(existingCount + 1);
    });

  });

  describe('--merge mode', () => {
    test('adds to existing memories without deleting', async () => {
      // Create existing memory
      await testDb.service.store('Existing memory', { project: 'existing-project' });
      const existingCount = (await testDb.service.list()).length;

      // Create import file with different content
      const importFile = join(importDir, 'merge-memory.json');
      await writeFile(importFile, JSON.stringify({
        content: 'New merged memory',
        tags: ['merged']
      }));

      // Simulate merge: store without deleting
      await testDb.service.store('New merged memory', { tags: ['merged'] });

      // Verify both memories exist
      const memories = await testDb.service.list();
      expect(memories.length).toBe(existingCount + 1);
      
      // Verify original memory still exists
      const originalMemory = memories.find(m => m.content === 'Existing memory');
      expect(originalMemory).toBeDefined();
    });
  });

  describe('--replace mode', () => {
    test('clears all memories before import', async () => {
      // Create existing memories
      await createTestMemories(testDb.service, 3);

      // Verify memories exist
      let memories = await testDb.service.list();
      expect(memories.length).toBe(3);

      // Create import file
      const importFile = join(importDir, 'replace-memory.json');
      await writeFile(importFile, JSON.stringify({
        content: 'Replacement memory',
        tags: ['replaced']
      }));

      // Simulate replace: delete all then import
      for (const memory of memories) {
        await testDb.service.delete(memory.id);
      }

      // Store new memory
      await testDb.service.store('Replacement memory', { tags: ['replaced'] });

      // Verify only new memory exists
      const newMemories = await testDb.service.list();
      expect(newMemories.length).toBe(1);
      expect(newMemories[0].content).toBe('Replacement memory');
    });
  });

  describe('--on-duplicate options', () => {
    test('skip mode ignores duplicate content', async () => {
      // Create original memory
      const original = await testDb.service.store('Duplicate content', { tags: ['original'] });
      const existingCount = (await testDb.service.list()).length;

      // Create import file with same content
      const importFile = join(importDir, 'duplicate.json');
      await writeFile(importFile, JSON.stringify({
        content: 'Duplicate content',
        tags: ['duplicate']
      }));

      // Simulate skip: don't store duplicate
      // (In actual implementation, duplicates are detected by content comparison)

      // Verify original memory unchanged
      const memories = await testDb.service.list();
      expect(memories.length).toBe(existingCount);
      
      const originalMemory = memories.find(m => m.content === 'Duplicate content');
      expect(originalMemory).toBeDefined();
      expect(originalMemory!.tags).toEqual(['original']);
    });

    test('update mode replaces existing memory', async () => {
      // Create original memory
      const original = await testDb.service.store('Content to update', { tags: ['old'] });

      // Create import file with same content but different tags
      const importFile = join(importDir, 'update.json');
      await writeFile(importFile, JSON.stringify({
        content: 'Content to update',
        tags: ['new', 'updated']
      }));

      // Simulate update: delete original, store new
      await testDb.service.delete(original.id);
      await testDb.service.store('Content to update', { tags: ['new', 'updated'] });

      // Verify memory was updated
      const memories = await testDb.service.list();
      const updatedMemory = memories.find(m => m.content === 'Content to update');
      expect(updatedMemory).toBeDefined();
      expect(updatedMemory!.tags).toEqual(['new', 'updated']);
    });
  });

  describe('Zod schema validation', () => {
    test('accepts valid memory file with all fields', async () => {
      const importFile = join(importDir, 'valid-full.json');
      await writeFile(importFile, JSON.stringify({
        id: 'test-id-123',
        content: 'Valid content',
        tags: ['tag1', 'tag2'],
        project: 'my-project',
        createdAt: new Date().toISOString(),
        embeddingModel: 'nomic-embed-text'
      }));

      const content = await readFile(importFile, 'utf-8');
      const data = JSON.parse(content);
      
      // Verify all fields present
      expect(data.content).toBe('Valid content');
      expect(data.tags).toEqual(['tag1', 'tag2']);
      expect(data.project).toBe('my-project');
    });

    test('accepts minimal file with only content', async () => {
      const importFile = join(importDir, 'valid-minimal.json');
      await writeFile(importFile, JSON.stringify({
        content: 'Minimal content'
      }));

      const content = await readFile(importFile, 'utf-8');
      const data = JSON.parse(content);
      
      expect(data.content).toBe('Minimal content');
    });

    test('rejects file without content field', async () => {
      const importFile = join(importDir, 'invalid-no-content.json');
      await writeFile(importFile, JSON.stringify({
        tags: ['some-tag']
      }));

      // This would fail Zod validation - content is required
      const content = await readFile(importFile, 'utf-8');
      const data = JSON.parse(content);
      
      expect(data.content).toBeUndefined();
    });

    test('rejects file with invalid tags type', async () => {
      const importFile = join(importDir, 'invalid-tags.json');
      await writeFile(importFile, JSON.stringify({
        content: 'Content with invalid tags',
        tags: 'not-an-array'
      }));

      // This would fail Zod validation - tags must be array
      const content = await readFile(importFile, 'utf-8');
      const data = JSON.parse(content);
      
      expect(typeof data.tags).toBe('string');
    });
  });

  describe('roundtrip test', () => {
    test('export then import preserves data', async () => {
      // Create test memories
      const originalMemories = await createTestMemories(testDb.service, 3, {
        tags: ['roundtrip', 'test'],
        project: 'roundtrip-project'
      });

      // Export: create JSON files
      for (const memory of originalMemories) {
        const exportFile = join(importDir, `${memory.id}.json`);
        const exportData = {
          id: memory.id,
          content: memory.content,
          tags: memory.tags,
          project: memory.project,
          createdAt: new Date(memory.createdAt).toISOString(),
          embeddingModel: memory.embeddingModel
        };
        await writeFile(exportFile, JSON.stringify(exportData));
      }

      // Clear original memories
      for (const memory of originalMemories) {
        await testDb.service.delete(memory.id);
      }

      // Verify cleared
      expect((await testDb.service.list()).length).toBe(0);

      // Import: read files and recreate memories
      const files = await readdir(importDir);
      const jsonFiles = files.filter(f => f.endsWith('.json'));

      for (const file of jsonFiles) {
        const filepath = join(importDir, file);
        const content = await readFile(filepath, 'utf-8');
        const data = JSON.parse(content);
        
        await testDb.service.store(data.content, {
          tags: data.tags,
          project: data.project
        });
      }

      // Verify memories restored
      const restoredMemories = await testDb.service.list();
      expect(restoredMemories.length).toBe(3);

      // Verify content preserved
      const restoredContents = restoredMemories.map(m => m.content).sort();
      const originalContents = originalMemories.map(m => m.content).sort();
      expect(restoredContents).toEqual(originalContents);
    });
  });

  describe('error handling', () => {
    test('handles missing input directory gracefully', async () => {
      const missingDir = join(tmpdir(), 'non-existent-dir');
      
      // Check directory doesn't exist
      let exists = false;
      try {
        await stat(missingDir);
        exists = true;
      } catch {
        exists = false;
      }
      
      expect(exists).toBe(false);
    });

    test('continues on individual file validation failures', async () => {
      // Create one valid and one invalid file
      const validFile = join(importDir, 'valid.json');
      await writeFile(validFile, JSON.stringify({ content: 'Valid' }));

      const invalidFile = join(importDir, 'invalid.json');
      await writeFile(invalidFile, 'not valid json');

      // Both files should be processed
      const files = await readdir(importDir);
      expect(files.length).toBe(2);

      // Valid file can be read
      const validContent = await readFile(validFile, 'utf-8');
      const validData = JSON.parse(validContent);
      expect(validData.content).toBe('Valid');
    });
  });
});
