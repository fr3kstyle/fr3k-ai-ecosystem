import type { Conversation, Message, ProviderType } from './types.js';

const conversations = new Map<string, Conversation>();

function generateId(): string {
  return `conv_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
}

export function createConversation(provider: ProviderType): string {
  const id = generateId();
  const conversation: Conversation = {
    id,
    provider,
    status: 'active',
    messages: [],
  };
  conversations.set(id, conversation);
  return id;
}

export function getConversation(id: string): Conversation | undefined {
  return conversations.get(id);
}

export function updateConversation(id: string, updates: Partial<Conversation>): void {
  const conversation = conversations.get(id);
  if (conversation) {
    Object.assign(conversation, updates);
  }
}

export function addMessage(conversationId: string, message: Message): void {
  const conversation = conversations.get(conversationId);
  if (conversation) {
    conversation.messages.push(message);
    conversation.lastMessageId = message.id;
  }
}

export function setUserResponse(conversationId: string, response: string): void {
  const conversation = conversations.get(conversationId);
  if (conversation) {
    conversation.userResponse = response;
  }
}

export function deleteConversation(id: string): void {
  conversations.delete(id);
}

export function endConversation(id: string): void {
  const conversation = conversations.get(id);
  if (conversation) {
    conversation.status = 'ended';
  }
}
