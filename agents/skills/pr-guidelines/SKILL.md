---
name: pr-guidelines
description: >
  Use when opening or updating a GitHub PR—`gh pr create`/`gh pr edit`, drafting title/body, choosing
  base branch, or refreshing description after new pushes. Triggers on "create PR", "PR description",
  "update the PR". Requires `gh`.
compatibility: Requires GitHub CLI (gh).
---

# PR Guidelines

## Context

Drafting or updating a PR needs the current branch (`git branch --show-current`), the working-tree state (`git status --short`), whether a PR already exists (`gh pr view --json number,baseRefName,title,url`), and recent commit messages for style (`git log --oneline -10`). Read them in one batch before drafting, reuse the results within the session, and report a failing command rather than assuming the state it would have shown.

## Drafting and publishing

Read the relevant diff and author intent, then draft the title and description using the conventions below. A drafting request ends with reviewable prose. Reuse the writing guidance already loaded in the session.

Commit, push, and remote PR changes each require authorization for that action. Complete the preparation and relevant checks before asking for any missing authorization. Existing authorization persists across turns.

For an authorized new PR, create a draft with an explicit base. Write multiline prose to a file and pass it with `--body-file` so formatting survives shell parsing.

After pushing to an existing PR, compare its title and description with the full diff. Revise the prose around the final scope. Publish the revision when PR editing is authorized, otherwise present the prepared text.

## Parameters

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

**Branch naming:** If the user mentions a ticket number (e.g., `PROJ-1234` — use your tracker's actual prefix), use it in the branch name from the start: `<handle>/proj-1234`. This ensures the tracker's PR auto-linking works and avoids renaming branches after PR creation. Without a ticket, name the branch for the change itself (`<handle>/checkout-retry-backoff`) — never invent a plausible-looking ticket number.

If any of these are unclear, ask before proceeding.

## PR Title

- Plain language in sentence case — no commit-style prefixes (`feat:`, `fix:`, etc.)
- Describe what changed, not the ticket number
- Concise but specific

## PR Description

Never use `##` headers in the PR body. Start directly with a paragraph explaining the problem, context, or motivation — why this PR exists. Then use bullet points describing what changed, focused on _what_ and _why_.

Never list more than 3–4 bullets in a row. Break longer lists into conceptual groups, each introduced by a sentence or two of prose. Readers should be able to scan at multiple levels of hierarchy — paragraph-level for the gist, bullet-level for details.

### Voice

- Present tense — "Adds validation for empty inputs" not "Added validation for empty inputs". This applies to both the opening paragraph and bullet points.
- Drop subject pronouns. Use "we" for team-level decisions or project direction. "I" only for genuinely first-person observations.
- Problem or motivation before solution. Explain what was broken, missing, or needed, then what was done.
- Direct — every sentence adds information. No preamble, hedging, or filler.
- Mention edge cases as asides or parentheticals, not dedicated sections.
- Group small related changes at the end with "Also:" or "A couple other semi-related changes:".
- Reference related work inline — link to tickets, Slack threads, Figma files, related PRs naturally in the text. For dependent PRs, see [Dependent and Cross-Repo PRs](#dependent-and-cross-repo-prs).

### Dependent and Cross-Repo PRs

A change spanning two repos (e.g. a frontend and the backend it calls) gets one PR per repo, each on a branch named for the shared ticket. Cross-link them in both descriptions with full URLs, stating what each side provides and what it depends on. Name non-obvious causes a reviewer can't infer from the diff — a transitive dependency bump forcing a direct-dependency version, an API contract the other side must ship first.

When ship order matters, block the downstream PR loudly so it can't merge early: set it to CHANGES_REQUESTED and add an all-caps note linking the blocker — `DO NOT MERGE UNTIL <linked PR> IS DEPLOYED TO PRODUCTION`. Remove the block once the dependency lands. Cross-repo edits belong in dedicated worktrees.

### Scale to PR Size

- **Small:** One or two sentences + screenshot/video if visual. Nothing more.
- **Medium:** Intro paragraph + bullet points + inline media + related links.
- **Large:** Same flat structure — no headers. Group related bullets under short prose paragraphs to create scannable sections.

<!-- harness: codex -->
### Codex description detail

For complex PRs, lean toward a little more detail. Three or four substantive sentences or short bullets often give enough room to explain the problem, resulting behavior, and key implications or tradeoffs. Include edge cases or dependencies when they affect review. Scale the length to the change, with each sentence adding useful detail. Simple PRs can stay at one or two sentences.
<!-- /harness -->

### Considered Alternatives

When alternatives were explored during development and intentionally rejected, include a brief note — inline or as a short closing paragraph (no header). Include it only when a reviewer seeing just the diff would plausibly ask "why not X", evidenced by a reverted commit, an abandoned approach in the history, or an explicit rejection in conversation. Skip alternatives that were never seriously attempted.

### Testing / Validation

Only include when testing is non-obvious — complex interactions, specific reproduction steps, or multi-step verification. For straightforward changes, code review and CI are sufficient.

When included, use a bulleted list for independent things to check, or an ordered list if steps must be done in sequence. Never use checkboxes. Describe what page to visit, what data needs to exist, what to look for.

### Visual Evidence

Many PRs would benefit from screenshots or videos to illustrate changes, but these can't be uploaded via GitHub's CLI or MCP. When the change is visual, capture the evidence with the available browser tools and hand the user the files to upload manually — don't defer it to an offered follow-up, and don't leave placeholder text in the PR body.

### Ticket References

Place `Fixes <ticket>` or `Closes <ticket>` on its own line, near the top (after opening context) or at the bottom. For related-but-not-closed tickets, use inline links.

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

## PR Comments and Interactions

Posting a comment, reply, or review on GitHub is a publish action. Do it when the user asks — including replying to their inline feedback on an agent's first-pass PR — but never unprompted. When asked only to "get" or "check" comments, present them in the conversation; don't reply on GitHub.

The agent posts through the user's own GitHub account, so attribution belongs in the body. Open every agent-authored comment with an italicized model name and colon, followed by the comment in the same paragraph:

*<model>:* <comment body>

Name the model actually running. Omit effort levels. Keep the body plain text in the same paragraph. Apply this attribution to inline review replies, review summaries, and conversation comments, including those posted via `/code-review --comment`. Write PR titles and descriptions in the user's voice without AI attribution.

Write for a reviewer without the session's context: open with the answer, restate referents the conversation coined, name code in the project's own terms, and cut the padding. A comment that reads like a mid-session chat update has not been re-pitched yet.
