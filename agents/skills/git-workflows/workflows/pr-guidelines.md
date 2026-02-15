# PR Guidelines

## Parameters

**Base branch:** Common patterns:

- `dev` — most feature work
- `main` or `master` — hotfixes or repos without a dev branch
- A feature branch — for sub-features of a larger effort

**Changes to include:** Determine if the PR should include:

- All uncommitted changes (staged + unstaged)
- Staged changes only (`git diff --cached`)
- Specific files

**Branch naming:** If the user mentions a ticket number (e.g., RMRK-1234), use it in the branch name from the start: `<handle>/rmrk-1234`. This ensures Linear auto-linking works and avoids renaming branches after PR creation.

If any of these are unclear, ask before proceeding.

## Pre-Submission Checks

Run all applicable checks before committing — type checks, linting, formatting, and tests.

## Writing the PR Title

- Use plain language, not commit-style prefixes (`fix:`, `feat:`)
- Describe what changed, not the ticket number
- Keep it concise but specific

## Writing the PR Description

Write PR descriptions in the user's voice — conversational, direct, first-person. The description should read like a short explanation to a teammate, not a report.

### Structure

**Always open with an introductory paragraph** — no `## Summary` header. Explain the problem being solved and why it matters. This is the most important part of the PR.

After the intro, use **flat bullet points** to describe what changed. Keep them focused on the *what* and *why*, not a file-by-file inventory.

**Scale structure to PR size:**

- **Small PRs:** One or two sentences + screenshot/video if visual. Nothing more.
- **Medium PRs:** Intro paragraph, bullet points, inline media, related links.
- **Large PRs:** Can use headers to organize, but only when the content genuinely needs them. Prefer descriptive headers (e.g., the name of a subsystem) over generic ones like "Changes".

### Voice and tone

- **Start with context, not a header.** Open with why this PR exists — the problem, the investigation, the customer report. Don't start with `## Summary`.
- **First person is fine, but use it sparingly.** Reserve "I" for personal observations — "I noticed this during testing", "I was initially skeptical of the dialog approach". For describing the software itself, use a detached voice: "Previously the system did X, now we do Y", "The loader was injecting CSS properties onto..." Use "we" for team decisions or project direction.
- **Problem before solution.** Explain what was broken or missing, then what was done about it.
- **Be direct.** No preamble, no hedging, no filler. Every sentence should add information.
- **State the situation, then describe the action.** Don't narrate the decision process or justify the approach — just explain what exists and what was done about it. "We have X, this PR does Y" not "Rather than doing X, I chose to do Y instead."
- **Mention edge cases as asides** rather than in dedicated sections — "This does *not* make a related update where..." or parenthetical notes.
- **Group small related changes** at the end with "Also:" or "Miscellaneous:" or "A couple other semi-related changes:" rather than burying them in the main narrative.
- **Reference related work naturally** — link to tickets, Slack threads, Figma files, related PRs inline rather than in a dedicated section.

### What to avoid

- **No `## Summary` / `## Test plan` scaffolding** — these are AI patterns. Open with prose, use `## Testing` or `## Validation` only when needed
- **No file-by-file change listings** — describe the *what* and *why* of changes, not a mechanical inventory
- **No LOC counts** ("~26 LOC thin wrapper (was ~190)")
- **No status information** like "all tests pass" or "ran typecheck" — this is assumed
- **No AI vocabulary** — "defense-in-depth", "leveraging", "ensuring robustness"
- **No decision narration** — "Rather than X, I extracted Y" or "Instead of fixing each spot individually..." reads as justifying choices. State the facts: "There are many places that assume X. This PR adds Y."
- **No numbered step-by-step behavioral flows** unless genuinely explaining a race condition or sequence-dependent bug
- **No `Fixes #123` as the entire body** — always explain *why*, even briefly

### Visual evidence

Embed screenshots and videos directly in the description body, near the text they illustrate. Don't put them in a separate "Screenshots" section. A video of the fix working is often better than a paragraph explaining it.

### Testing / Validation

Only include a `## Testing` or `## Validation` section when testing is non-obvious — complex interactions, specific reproduction steps, or multi-step verification. For straightforward changes, the code review and CI are sufficient.

When included, write simple prose steps a human can walk through — not checkboxes. Describe how to reproduce or confirm the fix: what page to navigate to, what data needs to exist, what to click, what to look for. The goal is a quick walkthrough, not a QA checklist.

### Ticket references

Place `Fixes RMRK-XXXX` or `Closes RMRK-XXXX` on its own line, either near the top (after the opening context) or at the bottom. For related-but-not-closed tickets, use inline links.
