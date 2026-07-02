---
name: pr-guidelines
description: >
  Use when opening or updating a GitHub PR—`gh pr create`/`gh pr edit`, drafting title/body, choosing
  base branch, or refreshing description after new pushes. Triggers on "create PR", "PR description",
  "update the PR". Requires `gh`.
compatibility: Requires GitHub CLI (gh).
global_category: Git
---

# PR Guidelines

## Context

- Branch: !`git branch --show-current 2>/dev/null`
- Status: !`git status --short 2>/dev/null`
- Existing PR: !`gh pr view --json number,baseRefName,title,url 2>/dev/null || echo "none"`
- Recent commits (for style): !`git log --oneline -10 2>/dev/null`

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
gh pr create --draft --title "Restore focus after closing dialogs" --body "$(cat <<'EOF'
PR body here...
EOF
)"
```

## Parameters

<!-- @> Verify base branch first: Conductor target → existing PR → repo convention → ask. Wrong base = wrong diff -->

**Base branch:** Determine the correct base before doing anything else — a wrong base makes the entire diff meaningless.

1. **Conductor workspace:** If a target branch is specified in the system instruction, use that (see `/conductor` for how Conductor sets workspace context).
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

**Branch naming:** If the user mentions a ticket number (e.g., `PROJ-1234` — use your tracker's actual prefix), use it in the branch name from the start: `<handle>/proj-1234`. This ensures the tracker's PR auto-linking works and avoids renaming branches after PR creation.

If any of these are unclear, ask before proceeding.

<!-- @> PR titles: plain language, no fix:/feat: prefixes -->

## PR Title

- Plain language in sentence case — no commit-style prefixes (`feat:`, `fix:`, etc.)
- Describe what changed, not the ticket number
- Concise but specific

<!-- @> No headers in PR body. Max 3-4 bullets per group; break longer lists with prose paragraphs. Problem before solution, direct, no filler -->

## PR Description

Never use `##` headers in the PR body. Start directly with a paragraph explaining the problem, context, or motivation — why this PR exists. Then use bullet points describing what changed, focused on _what_ and _why_.

Never list more than 3–4 bullets in a row. Break longer lists into conceptual groups, each introduced by a sentence or two of prose. Readers should be able to scan at multiple levels of hierarchy — paragraph-level for the gist, bullet-level for details.

<!-- @> Present tense ("Adds", not "Added"). Drop subject pronouns. "we" for team decisions, "I" for first-person only -->

### Voice

- Present tense — "Adds validation for empty inputs" not "Added validation for empty inputs". This applies to both the opening paragraph and bullet points.
- Drop subject pronouns. Use "we" for team-level decisions or project direction. "I" only for genuinely first-person observations.
- Problem or motivation before solution. Explain what was broken, missing, or needed, then what was done.
- Direct — every sentence adds information. No preamble, hedging, or filler.
- Mention edge cases as asides or parentheticals, not dedicated sections.
- Group small related changes at the end with "Also:" or "A couple other semi-related changes:".
- Reference related work inline — link to tickets, Slack threads, Figma files, related PRs naturally in the text. For dependent PRs, see [Dependent and Cross-Repo PRs](#dependent-and-cross-repo-prs).

<!-- @> Cross-repo change: one PR per repo on a shared ticket-named branch, cross-linked with full URLs; when ship order matters, block the downstream PR loudly (CHANGES_REQUESTED + DO NOT MERGE note) -->

### Dependent and Cross-Repo PRs

A change spanning two repos (e.g. a frontend and the backend it calls) gets one PR per repo, each on a branch named for the shared ticket. Cross-link them in both descriptions with full URLs, stating what each side provides and what it depends on. Name non-obvious causes a reviewer can't infer from the diff — a transitive dependency bump forcing a direct-dependency version, an API contract the other side must ship first.

When ship order matters, block the downstream PR loudly so it can't merge early: set it to CHANGES_REQUESTED and add an all-caps note linking the blocker — `DO NOT MERGE UNTIL <linked PR> IS DEPLOYED TO PRODUCTION`. Remove the block once the dependency lands. Cross-repo edits belong in dedicated worktrees, not a shared local branch — see `/git-workflows`.

### Scale to PR Size

- **Small:** One or two sentences + screenshot/video if visual. Nothing more.
- **Medium:** Intro paragraph + bullet points + inline media + related links.
- **Large:** Same flat structure — no headers. Group related bullets under short prose paragraphs to create scannable sections.

### Considered Alternatives

When alternatives were explored during development and intentionally rejected, include a brief note — either inline or in a short `## Considered but not done` section. Useful when a reviewer might naturally suggest the rejected approach. Infer when to include this from commit history or conversation context.

### Testing / Validation

Only include when testing is non-obvious — complex interactions, specific reproduction steps, or multi-step verification. For straightforward changes, code review and CI are sufficient.

When included, use a bulleted list for independent things to check, or an ordered list if steps must be done in sequence. Never use checkboxes. Describe what page to visit, what data needs to exist, what to look for.

### Visual Evidence

Many PRs would benefit from screenshots or videos to illustrate changes, but unfortunately these can't be uploaded via Github's CLI or MCP. Consider using the `/agent-browser` skill to document relevant visual evidence and provide the user with the files to upload manually. Don't leave placeholder text in the PR body, but ask the user if they would like a follow-up to capture screenshots.

### Ticket References

Place `Fixes <ticket>` or `Closes <ticket>` on its own line, near the top (after opening context) or at the bottom. For related-but-not-closed tickets, use inline links.

<!-- @> No file listings, counts/magnitudes/diff stats, diff-restating bullets, status info, AI vocabulary, decision narration, checkboxes, or "smoke test" -->

## What to Avoid

- File-by-file change listings or mechanical inventories (unless the refactoring is the point)
- Counts, magnitudes, or diff stats ("~75 instances", "~1600 usages", "+200 lines") — GitHub already shows these
- Restating what's obvious from the diff ("migrates all shorthand usages to their longhand equivalents") — describe what changed and why, not the mechanical operation
- **Never include status information** ("all tests pass", "ran typecheck", "type checks and linting pass") — CI results are assumed
- AI vocabulary ("defense-in-depth", "leveraging", "ensuring robustness")
- Decision narration ("Rather than X, I extracted Y") — state facts, not justifications. Use the "Considered Alternatives" section instead when rejection context is genuinely useful.
- Numbered step-by-step behavioral flows (unless explaining a race condition or sequence-dependent bug)
- `Fixes #123` as the entire body — always explain _why_
- `## Summary` / `## Test plan` scaffolding
- Checkboxes (task lists) — use plain bullets or ordered lists instead
- The phrase "smoke test"
- "Generated with Claude Code" or similar AI footers / co-authorship

<!-- @> Attribute agent-authored GitHub comments: italic "<provider> <model> (<effort>)" line, then blockquote body — the agent posts under the user's account. Not for PR titles/descriptions -->

## PR Comments and Interactions

Posting a comment, reply, or review on GitHub is a publish action. Do it when the user asks — including replying to their inline feedback on an agent's first-pass PR — but never unprompted. When asked only to "get" or "check" comments, present them in the conversation; don't reply on GitHub.

The agent posts through the user's own GitHub account, so author metadata can't tell an agent comment apart from the user's own — the attribution has to live in the body. Lead every agent-authored comment with an italicized provider-model-and-effort line, followed by a blockquote with the comment:

*<provider> <model> (<effort>)*:

> <comment body>

Fill in the model and effort actually running (`Claude Opus 4.8 (Max)`, `Codex 5.5 (Extra High)`). Keeping the whole agent voice inside one blockquote makes it read as a single offset unit, never confusable with the user's plain-text comments. This covers every agent-authored GitHub comment — inline review replies, review summaries, conversation comments — including those posted via `/code-review --comment`. It does not apply to PR titles or descriptions, which are written in the user's voice and still carry no AI footer.
