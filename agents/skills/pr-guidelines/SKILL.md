---
name: pr-guidelines
description: Review a pull request PR. Use when creating or updating a PR, writing PR descriptions, or running gh pr commands. Triggers on "open a PR", "create PR", "update PR description", "gh pr create", "gh pr edit".
compatibility: Requires GitHub CLI (gh).
global_category: Git
---

# PR Guidelines

## Procedure

1. Run `git status` to see changes
2. Use `gh pr diff` (for existing PRs) or `git diff origin/<base>...HEAD` (after fetching) to review changes — never diff against a local branch, which may be stale
3. Run `git log` to see commit message style
4. Run pre-submission checks (type checks, linting, formatting, tests)
5. Stage and commit with a concise message
6. Push branch to remote with `-u` flag
7. Draft the PR title and description following the guidelines below
8. Re-read the draft through the lens of the `/write` skill — edit sentence by sentence for clarity, concision, and craft. Even technical documentation should be a joy to read.
9. Create draft PR using `gh pr create --draft`

<!-- @> After pushing to an existing PR, review and update title/description to reflect current changes -->

## Updating an Existing PR

After pushing new commits to a branch with an open PR, **always** check whether the title and description still match the current state. Do this proactively — don't wait for the user to invoke `/pr-guidelines`.

1. Run `gh pr view` to read the current title and description
2. Compare against the full diff (`gh pr diff` or `git diff origin/<base>...HEAD`) — not just the new commits
3. Update title and/or description with `gh pr edit` if they no longer accurately reflect the PR's scope
4. Apply the `/write` skill to the revised description — edit for clarity and craft before submitting

The title and description should always describe the PR as a whole, not just the latest push. Apply the same voice and formatting rules from [PR Title](#pr-title) and [PR Description](#pr-description).

## Creating a New PR

Use HEREDOC for the PR body to preserve formatting:

```bash
gh pr create --draft --title "Fix login crash on empty session" --body "$(cat <<'EOF'
PR body here...
EOF
)"
```

## Parameters

<!-- @> Verify base branch first: Conductor target → existing PR → repo convention → ask. Wrong base = wrong diff -->
**Base branch:** Determine the correct base before doing anything else — a wrong base makes the entire diff meaningless.

1. **Conductor workspace:** If a target branch is specified in the system instruction, use that.
2. **Existing PR:** Run `gh pr view --json baseRefName -q .baseRefName` — the PR already knows its base.
3. **Convention:** Check the repo's default branch and branching model:
   - `dev` — most feature work in repos that use a dev branch
   - `main` or `master` — hotfixes or repos without a dev branch
   - A feature branch — for sub-features of a larger effort
4. **Ask** if still ambiguous.

Always `git fetch origin <base>` before diffing. Diff against `origin/<base>`, never a local branch.

**Changes to include:** Determine if the PR should include:

- All uncommitted changes (staged + unstaged)
- Staged changes only (`git diff --cached`)
- Specific files

**Branch naming:** If the user mentions a ticket number (e.g., RMRK-1234), use it in the branch name from the start: `<handle>/rmrk-1234`. This ensures Linear auto-linking works and avoids renaming branches after PR creation.

If any of these are unclear, ask before proceeding.

<!-- @> PR titles: plain language, no fix:/feat: prefixes -->

## PR Title

- Plain language in sentence case — no commit-style prefixes (`feat:`, `fix:`, etc.)
- Describe what changed, not the ticket number
- Concise but specific

<!-- @> Open with problem context, not ## Summary. Problem before solution. Direct, no filler -->

## PR Description

No opening `##` header. Start directly with a paragraph explaining the problem, context, or motivation — why this PR exists. Then use flat bullet points describing what changed, focused on _what_ and _why_.

<!-- @> Present tense ("Adds", not "Added"). Drop subject pronouns. "we" for team decisions, "I" for first-person only -->

### Voice

- Present tense — "Adds validation for empty inputs" not "Added validation for empty inputs". This applies to both the opening paragraph and bullet points.
- Drop subject pronouns. Use "we" for team-level decisions or project direction. "I" only for genuinely first-person observations.
- Problem or motivation before solution. Explain what was broken, missing, or needed, then what was done.
- Direct — every sentence adds information. No preamble, hedging, or filler.
- Mention edge cases as asides or parentheticals, not dedicated sections.
- Group small related changes at the end with "Also:" or "A couple other semi-related changes:".
- Reference related work inline — link to tickets, Slack threads, Figma files, related PRs naturally in the text.

### Scale to PR Size

- **Small:** One or two sentences + screenshot/video if visual. Nothing more.
- **Medium:** Intro paragraph + bullet points + inline media + related links.
- **Large:** Can use headers to organize. Prefer descriptive headers (e.g., subsystem name) over generic ones like "Changes".

### Considered Alternatives

When alternatives were explored during development and intentionally rejected, include a brief note — either inline or in a short `## Considered but not done` section. Useful when a reviewer might naturally suggest the rejected approach. Infer when to include this from commit history or conversation context.

### Testing / Validation

Only include when testing is non-obvious — complex interactions, specific reproduction steps, or multi-step verification. For straightforward changes, code review and CI are sufficient.

When included, use a bulleted list for independent things to check, or an ordered list if steps must be done in sequence. No checkboxes — except in draft PRs to show remaining work (remove them when moving to ready for review). Describe what page to visit, what data needs to exist, what to look for.

### Visual Evidence

Embed screenshots inline near the text they illustrate, not in a separate "Screenshots" section. Leave `[screenshot placeholder: <description of what to capture>]` markers for visual changes so the author can fill them in before merging.

### Ticket References

Place `Fixes <ticket>` or `Closes <ticket>` on its own line, near the top (after opening context) or at the bottom. For related-but-not-closed tickets, use inline links.

<!-- @> No file listings, LOC counts, status info, AI vocabulary, or decision narration -->

## What to Avoid

- File-by-file change listings or mechanical inventories (unless the refactoring is the point)
- LOC counts (unless the PR's purpose is reducing complexity or simplifying)
- **Never include status information** ("all tests pass", "ran typecheck", "type checks and linting pass") — CI results are assumed
- AI vocabulary ("defense-in-depth", "leveraging", "ensuring robustness")
- Decision narration ("Rather than X, I extracted Y") — state facts, not justifications. Use the "Considered Alternatives" section instead when rejection context is genuinely useful.
- Numbered step-by-step behavioral flows (unless explaining a race condition or sequence-dependent bug)
- `Fixes #123` as the entire body — always explain _why_
- `## Summary` / `## Test plan` scaffolding
- "Generated with Claude Code" or similar AI footers / co-authorship
