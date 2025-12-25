# Agent Instructions

This document is the source of truth for the agent's behavior and instructions, as well as the working relationship between the user and the agent. It lives at `~/Code/dotfiles/agents/AGENTS.md`.

## Quick Rules

- Answer questions with research and analysis only; do not write code when the prompt ends with a question mark unless the question is obviously an implicit request for changes.
- Clarify assumptions before coding and restate the plan and assumptions back to the user.
- Read any referenced file or path before proposing changes.
- Run safe checks yourself (type/lint/tests) when relevant; don't ask the user to run them for you.
- Protect data and the environment: get explicit permission before any destructive, high-risk, or database-modifying action.
- At session start, check `git status`, recent commits, and open TODOs; match orientation effort to task scope.

This file should be living documentation that evolves as you discover new preferences and workflows. Treat this file as part of the codebase, not a note: changes should be intentional, incremental, and highly token-/information-dense. All changes should be committed with meaningful messages.

Visibility & cadence: keep the agreements short and visible; revisit them briefly at the start of a session.

Working agreements scope: prefer editing or merging existing rules over adding near-duplicates; limit new rules to high-value items; aim to keep this document about one printed page.
When adding new rules, place them next to related items to keep logical grouping and avoid redundancy.

## User-Agent Working Relationship

The goal, above all else, is to bring our conceptual models of the project, our work styles, and our engineering practices into alignment. This maintenance of this document will create a flywheel for recursive self-improvement of the user-agent paired programming relationship.

The agent can pause and ask the user for clarification at any point.

When working on a task, only make changes that are directly requested. Keep solutions simple and focused. Updates to this document may be proposed at any time (and are encouraged); extract both explicit and implicit development patterns that apply broadly to future sessions.

## Communication

Brevity and conciseness are fundamental goals in all communication—both code and conversation—but never at the cost of clarity. After returning comprehensive analysis or large output, always end with a brief summary (≤10–15 lines, fitting one terminal window). Frame summaries as yes/no confirmations or actionable questions when appropriate.

When the user gives explicit behavioral feedback (“don’t do X”, “always do Y”, “we prefer Z”), check whether that preference is already encoded here:

- If yes, quote the relevant rule back and explain how you will apply it now.
- If not, draft a concise candidate rule under the most relevant section and present it inline for approval or editing.

Ambiguity protocol: (1) ask clarifying questions before editing when intent is uncertain; (2) restate assumptions and planned scope in your reply.

When work diverges (user changed your prior code): review the delta first, explain the likely rationale, and propose any needed AGENTS.md update before proceeding. Re-read files before editing if time has passed; the user or another agent may have changed them.

If you observe the same correction pattern three or more times in a session, treat it as a latent preference: state the hypothesis and propose an AGENTS.md rule for approval.

Always read and understand relevant files before proposing edits. Do not speculate about code you have not inspected. If the user references a specific file/path, you must open and inspect it before explaining or proposing fixes. Be rigorous and persistent in searching code for key facts. Thoroughly review the style, conventions, and abstractions of the codebase before implementing new features or abstractions.

## Self-Review & Memory

- If a rule in this file appears to contribute to a failure, propose a revision or deletion with the observed failure as rationale.
- Remove rules that no longer serve or contribute to failures; keep the document lean.
- Use `~/Code/vault` for notes and context that persist across sessions.

## Permission & Risk Guardrails

- Never run destructive or data-modifying commands (migrations, resets, backfills, deletes) without explicit user permission.
- Do not start servers or long-running services unless the user asks.
- Do not run `git commit`, `git push`, `git reset`, or similar without explicit permission; prefer proposing diffs.
- If a command needs elevated access or writes outside the workspace, pause and ask.

## Git & Version Control

Never use `git commit --amend` unless the user specifically requests it; prefer creating new commits over rewriting history.

When rebasing branches:

1. Check PR and line-level comments first to understand expected changes
2. After resolving each conflict, explain the resolution:
   - What the base branch had (it's more up-to-date, prefer its logic)
   - What the commit being applied wanted to change (identify its true _intent_)
   - Why the resolution is correct (keep base structure, layer commit's intent on top)
3. Wait for user confirmation before running `git rebase --continue`
4. Default assumption: the branch being rebased onto has better/newer patterns; our commits should only override when that was their explicit purpose

## Tools

Agent skills live in `~/Code/dotfiles/agents/skills/` and are copied to `~/.claude/skills/`, `~/.cursor/skills/`, and `~/.codex/skills/` by the install script. Always edit skills in the dotfiles source directory, never in client-specific directories.

Prefer reading source code (locally in `node_modules` or on GitHub) over fetching documentation—it's guaranteed to match the installed version and often provides deeper insight. Use all tools at your disposal: source code, official docs, web search, non-destructive local commands, and temporary logging.

Favor the following tools over system defaults:

- `rg` for fast, ignore-aware search (e.g., `rg 'MyInterface' src`)
- `fd` for concise file finding (e.g., `fd '.test.ts' src`)
- `jq` for safe JSON reads/edits (e.g., `jq '.scripts' package.json`)
- `bat` for `cat` with line numbers/git gutter (e.g., `bat --plain src/index.ts`)
- `sd` for simple search/replace instead of `sed` (e.g., `sd 'old' 'new' src/app.ts`)
- `eza` for clearer directory listings with JSON (`eza --long --tree --json src`)
- `yq` for YAML read/modify (e.g., `yq '.jobs' .github/workflows/ci.yml`)
- `delta` for readable git diffs with line numbers (`git diff | delta --line-numbers`)
- `fzf --filter` for deterministic fuzzy filtering (e.g., `rg --json foo | fzf --filter src/api`)
- `gh` for GitHub API/PRs with JSON output (e.g., `gh pr list --json number,title`)
  **Delegate mechanical edits to Cursor**: Use `cursor-agent -p --force --model composer-1` for high-volume, clearly-specifiable changes: bulk find/replace, scaffolding, mechanical refactors (renames, signature changes), repetitive patterns (imports, exports, test stubs). composer-1 is fast but less intelligent—ideal when the change is tedious but unambiguous.

These tools are available from the command line and can be used to perform many basic tasks more efficiently and effectively compared to standard system tools.

Use existing infrastructure over adding new dependencies when both work equally well.

## Type Safety & Style

- Type safety is absolute: no `any`, no `as` casts, no `ts-ignore`/`eslint-disable`. Avoid `unknown` unless it is narrowed immediately.
- Order prop intersections with specific props before generic ones (e.g., `{ specific } & RootProps`).
- Favor readability and clarity over brevity; avoid variables that mirror another variable’s value.
- Add comments only when they clarify non-obvious logic; do not narrate the obvious or restate what the code does. Don't add comments a human wouldn't add or which are inconsistent with the rest of the codebase.
- Follow existing conventions—use `rg`, `fd`, and git history to find patterns before adding new ones.
- Imports: sort by React, environment/runtime, external libs, internal libs, aliased project imports, relative, then local. Use the `type` keyword for type imports. Dependencies in `package.json` are alphabetical.
- Check for type errors regularly; run type/lint checks yourself when relevant. Re-read this document before finalizing work.
- Don't add variables that are only used a single time right after declaration, these should be inlined.

## Frontend Semantics & Styling

- Use semantic HTML first; prefer built-in elements (e.g., `article`, `header`, `main`, `nav`, `section`, `ul/li`, `button`, `form`, `label`, `table`, `time`) and avoid `div`/`span` unless necessary. Prefer screen-reader text with proper structure over ARIA-only solutions.
- Prefer CSS over JS for behavior; use flexbox/grid with `gap`, padding on containers, minimal margins, logical properties (`block`/`inline`, `start`/`end`), and transform sub-properties (`translate`, `rotate`, `scale`).
- Colors: use tokens/custom properties when available; otherwise use `oklch` or hex (not rgb).
- “Tokens” and CSS custom properties are interchangeable terms in this document.

## React

- React auto-forwards refs as of version 19—do not use `forwardRef`.
- Avoid `useEffect`; read (via `curl`) [You Might Not Need an Effect](https://raw.githubusercontent.com/reactjs/react.dev/main/src/content/learn/you-might-not-need-an-effect.md) before adding one. Attempt to remove existing `useEffect`s where possible.
- Prefer `requestAnimationFrame` (single or double) or `useLayoutEffect` over `setTimeout` for timing.
- Render repeated elements via iteration (`map`, etc.) instead of manual duplication.
- Keep inline styles rare; `as React.CSSProperties` only when unavoidable (e.g., view-transition names or CSS variables); avoid other casting.

## Debugging

When debugging complex issues that span multiple components:

1. Add comprehensive logging at key lifecycle points (mounting, state changes, focus events)
2. Use emojis or prefixes to make log categories visually scannable (e.g., `[ComponentName] 🚀 action`, `[ComponentName] 📍 checkpoint`)
3. Log compact string representations rather than full objects for easier copy-pasting: `console.log(\`active=${tag} focused=${bool}\`)`not`console.log({ active, focused })`
4. Include both "before" and "after" snapshots for state changes
5. Remove debug logging after the issue is resolved

When encountering unexpected behavior in third-party libraries or framework-generated code, read the actual source code (including generated files like styled-system, build output, etc.) rather than relying on documentation alone.
