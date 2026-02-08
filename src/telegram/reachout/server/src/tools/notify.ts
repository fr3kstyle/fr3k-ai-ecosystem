import type { Provider } from '../providers/base.js';
import type { ProviderType, ToolResult, Message, EmptySuccess } from '../types.js';
import { getConversation, createConversation, addMessage } from '../state.js';

export const notifyUserTool = {
  name: 'notify_user',
  description: 'Send one-way notification (no response expected)',
  inputSchema: {
    type: 'object' as const,
    properties: {
      provider: {
        type: 'string',
        enum: ['telegram', 'whatsapp'],
        default: 'telegram',
        description: 'Messaging provider to use',
      },
      conversation_id: {
        type: 'string',
        description: 'Optional - use existing conversation',
      },
      message: {
        type: 'string',
        description: 'Message to send',
      },
    },
    required: ['message'],
  },
};

export interface NotifyUserInput {
  provider?: ProviderType;
  conversation_id?: string;
  message: string;
}

export async function handleNotifyUser(
  input: NotifyUserInput,
  getProvider: (type: ProviderType) => Provider | undefined
): Promise<ToolResult<EmptySuccess>> {
  let providerType: ProviderType;
  let conversationId: string;

  // If conversation_id is provided, use that conversation's provider
  if (input.conversation_id) {
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
    providerType = conversation.provider;
    conversationId = input.conversation_id;
  } else {
    providerType = input.provider ?? 'telegram';
    conversationId = createConversation(providerType);
  }

  const provider = getProvider(providerType);
  if (!provider) {
    return {
      success: false,
      error: `Provider '${providerType}' is not configured`,
    };
  }

  try {
    // Create outbound message record
    const outboundMessage: Message = {
      id: `msg_${Date.now()}`,
      provider: providerType,
      text: input.message,
      timestamp: Date.now(),
      direction: 'outbound',
    };
    addMessage(conversationId, outboundMessage);

    // Send without waiting for response
    await provider.sendNoWait(input.message);

    return { success: true };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
