import type { ProviderType, SendResult } from '../types.js';

export interface Provider {
  readonly name: ProviderType;

  // Send message and return message ID
  send(text: string): Promise<SendResult>;

  // Send and wait for user response
  sendAndWait(text: string, timeoutMs: number): Promise<string>;

  // Send without waiting (fire-and-forget)
  sendNoWait(text: string): Promise<void>;

  // Clean up resources
  dispose(): void;
}
