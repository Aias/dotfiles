#!/usr/bin/env bash
set -euo pipefail

SESSION_FILE="$1"

echo "=== SESSION METADATA ==="
echo "File: $SESSION_FILE"
echo "Size: $(ls -lh "$SESSION_FILE" | awk '{print $5}')"
echo ""
echo "=== TOOL COUNTS ==="
jq -r 'select(.message.content[]?.name) | .message.content[].name' "$SESSION_FILE" | sort | uniq -c
echo ""
echo "=== FILES MODIFIED ==="
grep -o '"filePath":"[^"]*"' "$SESSION_FILE" | sort -u
