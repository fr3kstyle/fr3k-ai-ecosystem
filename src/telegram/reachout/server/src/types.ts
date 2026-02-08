export type ProviderType = 'telegram' | 'whatsapp';

export interface Message {
  id: string;
  provider: ProviderType;
  text: string;
  timestamp: number;
  direction: 'outbound' | 'inbound';
}

export interface Conversation {
  id: string;
  provider: ProviderType;
  status: 'active' | 'waiting' | 'ended';
  messages: Message[];
  lastMessageId?: string;
  userResponse?: string;
}

export interface SendResult {
  messageId: string;
  timestamp: number;
}

// Tool response types (consistent error handling)
export type ToolResult<T = object> =
  | ({ success: true } & T)
  | { success: false; error: string };

// Empty success response
export type EmptySuccess = Record<string, unknown>;

export interface SendMessageSuccess {
  conversation_id: string;
  user_response?: string;
}

export interface ContinueConversationSuccess {
  user_response: string;
}
