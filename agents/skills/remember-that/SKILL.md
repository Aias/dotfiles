---
name: remember-that
description: >
  Use when the user asks to remember something, change standing rules, or stop a repeated mistake—even
  without saying "skill". Also corrections and interruptions ("wait", "stop", "no", "undo that",
  "you keep doing X"). Persists to GLOBAL.md, a skill, AGENTS.md, or hooks as appropriate.
---

# Remember That

Extract durable learnings from conversation context and persist them appropriately. This skill is the decision point for _how and where_ context gets injected — whether passively (always-loaded rules in GLOBAL.md), on-demand (skills invoked by trigger), or enforced (hooks that remind or block before certain tool calls).

**Default: edit the relevant skill, GLOBAL.md, AGENTS.md, or hook directly.** When the user invokes `/remember-that`, they are giving explicit feedback — it almost always belongs in the canonical instructions, not in a `skill.feedback.md` scratch file. `skill.feedback.md` is reserved for the _agent's_ proactive recording of subtle preferences the user did not explicitly ask to be saved (see the feedback-loop note at the top of every skill).

> **Not Claude's built-in memory tool.** `/remember-that` always means: **edit a tracked file** — GLOBAL.md, a skill SKILL.md, project AGENTS.md/CLAUDE.md, or a hook. It never means: write to Claude's cross-conversation memory system (auto-memory, the `memory` tool, file-based memory under `~/.claude/projects/.../memory/`). Those systems are private to a single agent and invisible to other agents, other machines, and the user's git history — and in Conductor, each worktree is its own "project", so that memory is feature-scoped and won't even follow the repo. Harness memory is acceptable only for the agent's own project-local working context; anything the user says to remember belongs in the dotfiles repo so it's versioned, reviewable, and shared. If you find yourself reaching for a memory tool in response to `/remember-that`, stop — the right answer is always a file edit in this repo.

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

   | Scope               | Location                                                                                | When to use                                                                                                        |
   | ------------------- | --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
   | Global behavior     | `~/Code/dotfiles/agents/GLOBAL.md` (direct edit)                                        | Universal preferences not tied to any skill domain                                                                 |
   | Global (via skill)  | Skill SKILL.md + `<!-- @> summary -->` annotation                                       | Learning relates to a skill with `global_category` — edit the skill, add annotation, run `make compile`            |
   | Project-specific    | `./AGENTS.md` in project root (symlink `./CLAUDE.md → ./AGENTS.md`)                     | Patterns specific to this codebase, local conventions                                                              |
   | Workflow/technology | New or existing skill in `~/Code/dotfiles/agents/skills/` or local `.claude/skills`     | Detailed procedures for specific tools, frameworks, or workflows                                                   |
   | Enforcement         | Hook script in `~/Code/dotfiles/agents/hooks/` + registration in `claude.settings.json` | When a skill or rule must be loaded before certain tool calls (e.g. read `/pr-guidelines` before `gh pr` commands) |
   | Agent-proactive note | Skill's `skill.feedback.md` (e.g. `~/Code/dotfiles/agents/skills/write/skill.feedback.md`) | Agent-initiated only: subtle preference inferred during a skill session that the user did not explicitly ask to be saved. Not for `/remember-that` invocations. |

   **Decision heuristics:**
   - "Every conversation" → global GLOBAL.md (direct or via skill annotation)
   - "Every conversation in this project" → project root `AGENTS.md` (create `CLAUDE.md` symlink if missing)
   - "When working with X technology/workflow" → skill SKILL.md (edit directly)
   - Agent noticed a subtle pattern the user did not explicitly flag → skill's `skill.feedback.md` (lightweight, no confirmation needed). Never route a `/remember-that` invocation here.
   - "Must not forget to do X before Y" → companion hook that reminds or blocks. Hook matchers filter by tool name only (regex); command-content filtering happens inside the script.

   **Global via skill annotation:** When a learning falls within a skill that has `global_category` in its frontmatter (e.g. `/git-workflows`, `/react-best-practices`, `/change-review`), prefer editing/expanding the skill content AND adding a `<!-- @> token-dense summary -->` annotation above the relevant section. Then run `make compile` to regenerate the compiled GLOBAL.md index. This keeps the full context in the skill while surfacing a dense summary in always-loaded context.

   This only applies to the dotfiles-source GLOBAL.md — project-level AGENTS.md and CLAUDE.md have no compilation step.

   **Workspace sandboxing:** Conductor workspaces and other sandboxed environments restrict Edit/Write tools to the workspace directory. When you need to edit dotfiles source files (skills, GLOBAL.md, hooks, settings) from a sandboxed workspace, use Bash (e.g., `sed`) as a fallback. Always edit the source at `~/Code/dotfiles/`, never the installed/symlinked/workspace copies.

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

**User correction during `/write` session, invoked via `/remember-that`:** "Too formal, drop the semicolons"
**Extract:** Prefer shorter sentences, casual punctuation
**Location:** `~/Code/dotfiles/agents/skills/write/SKILL.md` (explicit feedback → edit the skill directly)

**Agent notices mid-session, no `/remember-that` invocation:** user rephrased a sentence to drop a hedging "perhaps" three times in a row
**Extract:** This user prefers direct phrasing over hedged
**Location:** `~/Code/dotfiles/agents/skills/write/skill.feedback.md` (agent-proactive note — never promoted without confirmation; eventually distilled via `/refine-skills`)

## Distilling Feedback

When a skill's `skill.feedback.md` has accumulated enough entries (~10+), use `/refine-skills` to promote patterns into permanent SKILL.md instructions and clean up the feedback file. This is the mechanism that turns raw accumulation into compounding improvement.

## Anti-patterns

- Don't persist task-specific details ("remember to fix the login bug")
- Don't duplicate existing rules in different words
- Don't add rules that contradict existing ones without consolidating
- Don't create new skills for single simple rules — use GLOBAL.md or project AGENTS.md
