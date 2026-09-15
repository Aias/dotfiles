---
name: orient
description: >
  Reconstruct unfinished repository work when the user asks to resume, catch up, or use /orient
  and the active context is missing or stale. A new task in an unfamiliar repo needs only its relevant context.
global_category: Workflow
---

# Orient

Recover enough context to continue the user's task. Read current branch, working-tree state, and recent commits before describing work as unfinished. Reuse fresh context already gathered in the session.

<!-- @> When resuming stale or missing context, refresh relevant branch, PR, and working-tree state before claiming work is unfinished; continue the requested task after orientation -->
For work that depends on branch history, resolve the base from the Conductor target, existing PR, or repository convention, then fetch the needed ref. Use pr-guidelines for PR-specific conventions.

Inspect the relevant unfinished work: active changes, PR discussion or failing checks, session notes, and background services started for the task. Read architecture and project documentation where they explain that work. Use [fresh-repo diagnostics](references/fresh-repo-diagnostics.md) for a requested repository assessment.

Summarize the current objective, completed work, remaining work, and any blocker. Include branch or PR details only when they affect the next action. Continue the requested task. Ask for direction when the user has not supplied an objective and the evidence leaves several plausible ones.
