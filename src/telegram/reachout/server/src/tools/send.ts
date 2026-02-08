import type { Provider } from '../providers/base.js';
import type { ProviderType, ToolResult, SendMessageSuccess, Message } from '../types.js';
import { createConversation, addMessage, updateConversation } from '../state.js';

export const sendMessageTool = {
  name: 'send_message',
  description: 'Send a message to user and optionally wait for response',
  inputSchema: {
    type: 'object' as const,
    properties: {
      provider: {
        type: 'string',
        enum: ['telegram', 'whatsapp'],
        default: 'telegram',
        description: 'Messaging provider to use',
      },
      message: {
        type: 'string',
        description: 'Message to send',
      },
      wait_for_response: {
        type: 'boolean',
        default: true,
        description: 'Whether to wait for user response',
      },
      timeout_ms: {
        type: 'number',
        default: 300000,
        description: 'Timeout in milliseconds when waiting for response',
      },
    },
    required: ['message'],
  },
};

export interface SendMessageInput {
  provider?: ProviderType;
  message: string;
  wait_for_response?: boolean;
  timeout_ms?: number;
}

export async function handleSendMessage(
  input: SendMessageInput,
  getProvider: (type: ProviderType) => Provider | undefined
): Promise<ToolResult<SendMessageSuccess>> {
  const providerType = input.provider ?? 'telegram';
  const provider = getProvider(providerType);

  if (!provider) {
    return {
      success: false,
      error: `Provider '${providerType}' is not configured`,
    };
  }

  const waitForResponse = input.wait_for_response ?? true;
  const timeoutMs = input.timeout_ms ?? 300000;

  try {
    // Create a new conversation
    const conversationId = createConversation(providerType);

    // Create outbound message record
    const outboundMessage: Message = {
      id: `msg_${Date.now()}`,
      provider: providerType,
      text: input.message,
      timestamp: Date.now(),
      direction: 'outbound',
    };
    addMessage(conversationId, outboundMessage);

    if (waitForResponse) {
      updateConversation(conversationId, { status: 'waiting' });
      const userResponse = await provider.sendAndWait(input.message, timeoutMs);

      // Create inbound message record
      const inboundMessage: Message = {
        id: `msg_${Date.now()}`,
        provider: providerType,
        text: userResponse,
        timestamp: Date.now(),
        direction: 'inbound',
      };
      addMessage(conversationId, inboundMessage);
      updateConversation(conversationId, { status: 'active', userResponse });

      return {
        success: true,
        conversation_id: conversationId,
        user_response: userResponse,
      };
    } else {
      await provider.sendNoWait(input.message);
      return {
        success: true,
        conversation_id: conversationId,
      };
    }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
