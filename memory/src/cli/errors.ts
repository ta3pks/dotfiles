export const EXIT_SUCCESS = 0;
export const EXIT_ERROR = 1;
export const EXIT_VALIDATION = 2;
export const EXIT_NOT_FOUND = 3;

export class CLIError extends Error {
  constructor(
    message: string,
    public exitCode: number = EXIT_ERROR
  ) {
    super(message);
    this.name = 'CLIError';
  }
}

export class ValidationError extends CLIError {
  constructor(message: string) {
    super(message, EXIT_VALIDATION);
    this.name = 'ValidationError';
  }
}

export class NotFoundError extends CLIError {
  constructor(message: string) {
    super(message, EXIT_NOT_FOUND);
    this.name = 'NotFoundError';
  }
}

export async function checkOllama(): Promise<void> {
  const { checkOllamaHealth } = await import('../embeddings/index.js');
  const healthy = await checkOllamaHealth();
  if (!healthy) {
    throw new CLIError(
      'Ollama is not running. Start with: systemctl --user start ollama'
    );
  }
}
