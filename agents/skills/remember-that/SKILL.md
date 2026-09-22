---
name: remember-that
description: >
  Persist a requested standing preference or a correction explicitly intended for future tasks.
  Routes guidance to GLOBAL.md, project instructions, skills, or hooks.
  One-off stops, approvals, and undo requests stay in the current task.
global_category: Workflow
---

# Remember that

<!-- @> A task-specific instruction does not establish a standing preference -->
Capture guidance that should change behavior on future tasks. Apply the user's immediate correction first. A task-specific instruction does not imply a new standing rule.

Read the relevant existing guidance before adding anything. Quote an existing rule when it already covers the preference. Otherwise consolidate overlapping instructions and describe the applicable condition. Use a representative example only when the rule would be ambiguous without it.

## Choose a home

| Guidance | Source |
| --- | --- |
| Cross-project behavior | `~/Code/dotfiles/agents/GLOBAL.md` |
| Workflow or tool knowledge | A skill under `~/Code/dotfiles/agents/skills/` |
| Machine-specific or private guidance | `~/Code/dotfiles/agents/skills.local/` |
| Project conventions | The project's `AGENTS.md` |
| Deterministic enforcement | A hook and its harness registration |
| An inferred preference needing later review | The relevant skill's `skill.feedback.md` |

Edit dotfiles sources, not installed copies. Keep private information out of tracked files in the public dotfiles repository. Harness-private memory can hold working context, but shared standing rules belong in the source files above.

For a skill with `global_category`, add an annotation only when the rule belongs in every relevant session. Keep detailed procedures in the skill. Use harness sections for guidance that applies only to a particular harness.

## Apply the change

An explicit request to save a specific preference authorizes the corresponding edit. If the inferred rule would broaden the user's request or change an existing preference, show the proposed wording and location for approval. Existing authorization persists across turns.

After an authorized edit to dotfiles guidance, run `make compile` and `make link`, then commit and push as GLOBAL.md's dotfiles rule directs. Report what was saved and where. Read the refine-skills skill when the task is to distill accumulated feedback.
