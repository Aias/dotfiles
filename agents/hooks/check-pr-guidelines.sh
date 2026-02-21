#!/usr/bin/env bash
# PreToolUse hook: remind model to read pr-guidelines skill before gh pr commands
COMMAND=$(jq -r '.tool_input.command // empty')
if echo "$COMMAND" | grep -qE '\bgh\s+pr\b'; then
  jq -n '{
    hookSpecificOutput: {
      additionalContext: "REMINDER: Read the pr-guidelines skill before running gh pr commands, if you have not already this session."
    }
  }'
fi
