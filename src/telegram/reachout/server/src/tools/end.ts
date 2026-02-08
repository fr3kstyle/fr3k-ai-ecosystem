import type { Provider } from '../providers/base.js';
import type { ProviderType, ToolResult, Message, EmptySuccess } from '../types.js';
import { getConversation, addMessage, endConversation } from '../state.js';

export const endConversationTool = {
  name: 'end_conversation',
  description: 'Send final message and end conversation',
  inputSchema: {
    type: 'object' as const,
    properties: {
      conversation_id: {
        type: 'string',
        description: 'ID of the conversation to end',
      },
      message: {
        type: 'string',
        description: 'Final message to send',
      },
    },
    required: ['conversation_id', 'message'],
  },
};

export interface EndConversationInput {
  conversation_id: string;
  message: string;
}

export async function handleEndConversation(
  input: EndConversationInput,
  getProvider: (type: ProviderType) => Provider | undefined
): Promise<ToolResult<EmptySuccess>> {
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
      error: 'Conversation has already ended',
    };
  }

  const provider = getProvider(conversation.provider);
  if (!provider) {
    return {
      success: false,
      error: `Provider '${conversation.provider}' is not configured`,
    };
  }

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

    // Send the final message
    await provider.sendNoWait(input.message);

    // Mark conversation as ended
    endConversation(input.conversation_id);

    return { success: true };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
