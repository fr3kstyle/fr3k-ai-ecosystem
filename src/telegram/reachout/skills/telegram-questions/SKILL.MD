# Telegram Questions Skill

Use this skill when you need to communicate with the user via Telegram instead of the terminal.

## When to Use Telegram

### Ask Questions When Stuck
When you encounter any of these situations, use Telegram to ask the user:
- Need clarification on requirements or approach
- Multiple valid implementation options exist
- Missing information needed to proceed
- Encountered an unexpected error or blocker
- Need confirmation before making significant changes

### Notify When Done
Send a Telegram notification when:
- A long-running task completes (builds, tests, deployments)
- You've finished implementing a requested feature
- You've encountered a critical error that stops progress
- Background work has completed

## How to Use

### Starting a Conversation (Ask and Wait)
```
Use the `send_message` MCP tool:
- provider: "telegram"
- message: Your question or status update
- wait_for_response: true (to wait for user reply)
- timeout_ms: 300000 (5 minutes, adjust as needed)
```

### Follow-up Questions
```
Use the `continue_conversation` MCP tool:
- conversation_id: The ID from the initial send_message
- message: Your follow-up question
```

### One-way Notifications
```
Use the `notify_user` MCP tool:
- message: Your notification text
- provider: "telegram"
```

### Ending a Conversation
```
Use the `end_conversation` MCP tool:
- conversation_id: The conversation ID
- message: Final message to send
```

## Behavior Guidelines

1. **Prefer Telegram over AskUserQuestion** - When this skill is active, use Telegram messaging tools instead of the built-in AskUserQuestion tool for all user interactions.

2. **Be concise** - Telegram messages should be brief and actionable. Include only essential information.

3. **Provide options** - When asking questions, offer numbered choices when possible for easy mobile responses.

4. **Include context** - Briefly mention what you're working on so the user has context when they see the notification.

5. **Don't spam** - Batch related questions together rather than sending multiple separate messages.

## Example Flows

### Asking for Clarification
```
Me: "Working on the API endpoint. Quick question:

Which authentication method should I use?
1. JWT tokens
2. API keys
3. OAuth 2.0"

User replies: "2"

Me: *continues with API key implementation*
```

### Notifying on Completion
```
Me: "Done! Created the user authentication system:
- Login/logout endpoints
- Password hashing with bcrypt
- Session management

All tests passing. Ready for review."
```

### Reporting a Blocker
```
Me: "Hit a blocker: The database connection is failing with 'ECONNREFUSED'.

Is the database server running? Or should I update the connection config?"

User replies: "Let me start it... ok try now"

Me: *retries and continues*
```
