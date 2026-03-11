import type { ModelName } from "./models.js";
import { DEFAULT_MODEL } from "./models.js";

const OLLAMA_URL = process.env.OLLAMA_URL || "http://localhost:11434";

interface EmbedRequest {
  model: string;
  input: string | string[];
  truncate?: boolean;
}

interface EmbedResponse {
  model: string;
  embeddings: number[][];
  total_duration: number;
  prompt_eval_count: number;
}

export interface EmbeddingResult {
  embedding: number[];
  tokenCount: number;
  model: string;
}

export async function getEmbedding(
  text: string,
  model: ModelName = DEFAULT_MODEL
): Promise<EmbeddingResult> {
  const response = await fetch(`${OLLAMA_URL}/api/embed`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model,
      input: text,
      truncate: true
    } satisfies EmbedRequest)
  });
  
  if (!response.ok) {
    throw new Error(`Ollama embedding failed: ${response.status} ${response.statusText}`);
  }
  
  const data: EmbedResponse = await response.json();
  
  if (!data.embeddings || data.embeddings.length === 0) {
    throw new Error("Ollama returned no embeddings");
  }
  
  return {
    embedding: data.embeddings[0],
    tokenCount: data.prompt_eval_count,
    model: data.model
  };
}

export async function getBatchEmbeddings(
  texts: string[],
  model: ModelName = DEFAULT_MODEL
): Promise<EmbeddingResult[]> {
  const response = await fetch(`${OLLAMA_URL}/api/embed`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model,
      input: texts,
      truncate: true
    } satisfies EmbedRequest)
  });
  
  if (!response.ok) {
    throw new Error(`Ollama batch embedding failed: ${response.status}`);
  }
  
  const data: EmbedResponse = await response.json();
  
  return data.embeddings.map((embedding, i) => ({
    embedding,
    tokenCount: data.prompt_eval_count,
    model: data.model
  }));
}

export async function checkOllamaHealth(): Promise<boolean> {
  try {
    const response = await fetch(`${OLLAMA_URL}/api/tags`, {
      method: "GET",
      signal: AbortSignal.timeout(2000)
    });
    return response.ok;
  } catch {
    return false;
  }
}

export async function listAvailableModels(): Promise<string[]> {
  const response = await fetch(`${OLLAMA_URL}/api/tags`);
  
  if (!response.ok) {
    throw new Error(`Failed to list Ollama models: ${response.status}`);
  }
  
  const data = await response.json() as { models: Array<{ name: string }> };
  return data.models.map(m => m.name);
}
