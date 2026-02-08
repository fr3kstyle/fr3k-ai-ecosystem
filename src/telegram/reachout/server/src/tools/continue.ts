import type { Provider } from '../providers/base.js';
import type { ProviderType, ToolResult, ContinueConversationSuccess, Message } from '../types.js';
import { getConversation, addMessage, updateConversation } from '../state.js';

export const continueConversationTool = {
  name: 'continue_conversation',
  description: 'Send follow-up message in existing conversation and wait for response',
  inputSchema: {
    type: 'object' as const,
    properties: {
      conversation_id: {
        type: 'string',
        description: 'ID of the conversation to continue',
      },
      message: {
        type: 'string',
        description: 'Message to send',
      },
      timeout_ms: {
        type: 'number',
        default: 300000,
        description: 'Timeout in milliseconds when waiting for response',
      },
    },
    required: ['conversation_id', 'message'],
  },
};

export interface ContinueConversationInput {
  conversation_id: string;
  message: string;
  timeout_ms?: number;
}

export async function handleContinueConversation(
  input: ContinueConversationInput,
  getProvider: (type: ProviderType) => Provider | undefined
): Promise<ToolResult<ContinueConversationSuccess>> {
  const conversation = getConversation(input.conversation_id);

  if (!conversation) {
    return {
      success: false,
      error: `Conversation '${input.conversation_id}' not found`,
    };
  }

  if (conversation.status === 'ended') {
    return {
      success: false,
      error: 'Conversation has ended',
    };
  }

  const provider = getProvider(conversation.provider);
  if (!provider) {
    return {
      success: false,
      error: `Provider '${conversation.provider}' is not configured`,
    };
  }

  const timeoutMs = input.timeout_ms ?? 300000;

  try {
    // Create outbound message record
    const outboundMessage: Message = {
      id: `msg_${Date.now()}`,
      provider: conversation.provider,
      text: input.message,
      timestamp: Date.now(),
      direction: 'outbound',
    };
    addMessage(input.conversation_id, outboundMessage);
    updateConversation(input.conversation_id, { status: 'waiting' });

    // Send and wait for response
    const userResponse = await provider.sendAndWait(input.message, timeoutMs);

    // Create inbound message record
    const inboundMessage: Message = {
      id: `msg_${Date.now()}`,
      provider: conversation.provider,
      text: userResponse,
      timestamp: Date.now(),
      direction: 'inbound',
    };
    addMessage(input.conversation_id, inboundMessage);
    updateConversation(input.conversation_id, { status: 'active', userResponse });

    return {
      success: true,
      user_response: userResponse,
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
