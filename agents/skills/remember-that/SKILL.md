---
name: remember-that
description: |
  Persist learnings and enforce patterns across sessions. Triggers on: "remember that", "add this to the rules", "update GLOBAL.md", "save this preference", "add a hook for", "enforce this", "make sure the agent always", "inject this context when", "never forget to". Also triggers on user corrections and interruptions — "wait", "stop", "no", "undo that", "don't do that", "that's wrong", "I said X not Y", "you keep doing X" — since repeated corrections signal a pattern worth persisting. Determines the right mechanism: always-loaded rules (GLOBAL.md), on-demand skills, project instructions (AGENTS.md), or enforcement hooks.
---

# Remember That

Extract durable learnings from conversation context and persist them appropriately. This skill is the decision point for *how and where* context gets injected — whether passively (always-loaded rules in GLOBAL.md), on-demand (skills invoked by trigger), or enforced (hooks that remind or block before certain tool calls).

## Process

1. **Analyze recent context** — Review the last few user messages and the conversation thread to identify what the user wants remembered. Look for:

   - Explicit corrections ("don't do X", "always do Y")
   - Preferences revealed through feedback ("I prefer...", "that's too verbose")
   - Patterns that emerged during the session
   - Implicit standards the user enforced

2. **Filter for durability** — Only persist learnings that are:

   - General principles or repeatable patterns (not one-off task details)
   - Applicable across multiple sessions
   - Not already captured in existing rules

3. **Determine storage location(s)** — A learning may require edits to multiple files:

   | Scope               | Location                                                                            | When to use                                                                        |
   | ------------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
   | Global behavior     | `~/Code/dotfiles/agents/GLOBAL.md` (direct edit)                                    | Universal preferences not tied to any skill domain                                 |
   | Global (via skill)  | Skill SKILL.md + `<!-- @> summary -->` annotation                                   | Learning relates to a skill with `global_category` — edit the skill, add annotation, run `make compile` |
   | Project-specific    | `./AGENTS.md` in project root (symlink `./CLAUDE.md → ./AGENTS.md`)                 | Patterns specific to this codebase, local conventions                              |
   | Workflow/technology | New or existing skill in `~/Code/dotfiles/agents/skills/` or local `.claude/skills` | Detailed procedures for specific tools, frameworks, or workflows                   |
   | Enforcement         | Hook script in `~/Code/dotfiles/agents/hooks/` + registration in `claude.settings.json` | When a skill or rule must be loaded before certain tool calls (e.g. read pr-guidelines before `gh pr` commands) |

   **Decision heuristics:**

   - "Every conversation" → global GLOBAL.md (direct or via skill annotation)
   - "Every conversation in this project" → project root `AGENTS.md` (create `CLAUDE.md` symlink if missing)
   - "When working with X technology/workflow" → skill
   - "Must not forget to do X before Y" → companion hook that reminds or blocks. Hook matchers filter by tool name only (regex); command-content filtering happens inside the script.

   **Global via skill annotation:** When a learning falls within a skill that has `global_category` in its frontmatter (e.g., `git-workflows`, `react-best-practices`, `typescript-guidelines`), prefer editing/expanding the skill content AND adding a `<!-- @> token-dense summary -->` annotation above the relevant section. Then run `make compile` to regenerate the compiled GLOBAL.md index. This keeps the full context in the skill while surfacing a dense summary in always-loaded context.

   This only applies to the dotfiles-source GLOBAL.md — project-level AGENTS.md and CLAUDE.md have no compilation step.

4. **Consolidate, don't accumulate** — Before adding:

   - Read the target file(s)
   - Check if a more general rule would capture this + existing related rules
   - Merge overlapping instructions into one
   - Prefer editing existing rules over adding new ones
   - Delete redundant rules when consolidating

5. **Propose changes** — Use `AskUserQuestion` to present:

   - What will be remembered (the extracted principle)
   - Where it will go (file path and section)
   - How it relates to existing rules (consolidation, replacement, or addition)
   - The exact diff or new text

   Wait for explicit user confirmation before making any edits.

## Examples

**User feedback:** "Stop adding docstrings to functions I didn't modify"
**Extract:** Don't add comments/docstrings to unchanged code
**Location:** GLOBAL.md (universal coding practice)
**Check:** Already covered by "only make changes that are directly requested" → no edit needed, just acknowledge

**User feedback:** "In this repo we use pnpm, not npm"
**Extract:** Use pnpm as package manager
**Location:** Project AGENTS.md (project-specific)

**User feedback:** "When reviewing PRs, always check for console.log statements"
**Extract:** PR review should flag debug statements
**Location:** `pr-review` skill (workflow-specific)

## Anti-patterns

- Don't persist task-specific details ("remember to fix the login bug")
- Don't duplicate existing rules in different words
- Don't add rules that contradict existing ones without consolidating
- Don't create new skills for single simple rules — use GLOBAL.md or project AGENTS.md
