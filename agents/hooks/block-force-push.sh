#!/usr/bin/env bash
# PreToolUse hook: block force push — the user always force pushes manually
COMMAND=$(jq -r '.tool_input.command // empty')
if echo "$COMMAND" | grep -qE '\bgit\s+push\b.*--force'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Force push is never allowed by the agent. If remote history needs rewriting, the user will do it manually."
    }
  }'
fi
