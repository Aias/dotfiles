---
name: diary
description: Create a structured diary entry from the current session transcript
---

# Create Diary Entry from Current Session

You are going to create a structured diary entry that documents what happened in the current working session. This entry will be used later for reflection and pattern identification.

## Approach: Context-First Strategy

**Primary Method (use this first):**
Reflect on the conversation history loaded in this session. You have access to:

- All user messages and requests
- Your responses and tool invocations
- Files you read, edited, or wrote
- Errors encountered and solutions applied
- Design decisions discussed
- User preferences expressed

**When to use JSONL fallback (rare):**

- Session was compacted and context is incomplete
- You need precise statistics (exact tool counts, timestamps)
- User specifically requests detailed session analysis

## Steps to Follow

### 1. Create Diary Entry from Context (Primary Method)

Review the current conversation and create a diary entry based on what happened. No tool invocations needed for typical sessions.

Skip to Step 4 to write the diary entry.

### 2. Fallback: Locate Session Transcript (Only if context insufficient)

If you determine context is insufficient, run this command to find the transcript:

```bash
# Find the most recent session file for this project
# NOTE: Path format includes leading dash: -Users-name-Code-app
SESSION_FILE=$(ls -t ~/.claude/projects/-$(echo "{{ cwd }}" | sed 's/\//‐/g')/*.jsonl 2>/dev/null | head -1) && \
if [ -z "$SESSION_FILE" ]; then \
  echo "ERROR: No session file found" && \
  echo "Looking in: ~/.claude/projects/-$(echo "{{ cwd }}" | sed 's/\//‐/g')/" && \
  ls -la ~/.claude/projects/ | head -20; \
else \
  echo "FOUND: $SESSION_FILE" && \
  ls -lh "$SESSION_FILE"; \
fi
```

**What this does:**

- Converts current directory to project hash format (e.g., `/Users/name/Code/app` → `-Users-name-Code-app`)
- Note the LEADING DASH in the path format
- Finds the most recent `.jsonl` file in that project's directory

### 3. Fallback: Extract Key Metadata (Only if needed)

Only run this if you need precise statistics:

```bash
scripts/extract-session-metadata.sh "[path-from-step-2]"
```

This is a simplified extraction - only metadata, tool counts, and files. Much faster than the old approach.

### 4. Create the Diary Entry

Based on the conversation context (and optional metadata from Step 3), create a diary entry for the current date. The diary file uses the format `YYYY-MM-DD.md` (e.g., `2025-12-11.md`) in `~/Code/vault/diary/`.

**Important**: There is only one diary file per day. If the file already exists, append the new entry with a divider (`---`) and two newlines before it. If the file doesn't exist, create it with the entry.

See the template in `references/entry-template.md`.

### 4. Save the Diary Entry

Run this command to determine the diary file path for today:

```bash
scripts/diary-file-path.sh
```

Use the Write tool to write the diary content:

- If the file doesn't exist, create it with the diary entry
- If the file already exists, append the new entry with a divider (`---`) and two newlines before it
- This ensures all entries for a given day are in a single file

### 5. Confirm Completion

Display:

- Path where diary was saved
- Brief summary of what was captured

## Important Guidelines

- **Be factual and specific**: Include concrete details (file paths, error messages)
- **Capture the 'why'**: Explain reasoning behind decisions
- **Document ALL user preferences**: Especially around commits, PRs, linting, testing
- **Include failures**: What didn't work is valuable learning
- **Keep it structured**: Follow the template consistently
- **Use context first**: Only parse JSONL files when truly necessary

## Decision Guide: When to Use Each Approach

| Situation                | Approach           | Reasoning                               |
| ------------------------ | ------------------ | --------------------------------------- |
| During active session    | **Context only**   | All information available, 0 tool calls |
| PreCompact hook trigger  | **Context only**   | Session still in memory                 |
| Post-session analysis    | **JSONL fallback** | Context no longer available             |
| Need exact statistics    | **JSONL metadata** | Precise counts unavailable from context |
| User says "create diary" | **Context first**  | Assume current session unless specified |

## Error Handling

**Context-based errors:**

- If context seems incomplete, mention what's missing and offer to use JSONL fallback
- If uncertain about details, document with "approximately" or "unclear from context"

**JSONL-based errors:**

- If session file not found, show where you looked (remember: `-Users-...` format with leading dash)
- Check `ls -la ~/.claude/projects/` to help diagnose path issues
- If transcript is malformed, document what you could parse and fall back to context
