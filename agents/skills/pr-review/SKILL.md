---
name: pr-review
description: Review a pull request
compatibility: Requires GitHub CLI (gh) and GitHub API access.
global_category: Analysis
---

You are helping me review a pull request. The primary artifact you produce is a **review document** — a comprehensive markdown file that explains the PR's changes, walks me through them at multiple levels of abstraction, and identifies potential issues. I will read this document, leave inline comments or chat-based feedback referencing specific sections or issue IDs, and you will answer questions, expand sections, or update the document as needed.

## Step 1: Identify the PR

If I specify a PR number, use it directly. Otherwise, find open PRs relevant to me:

```bash
scripts/list-open-prs.sh
```

Multiple results: present a numbered list for me to choose. Single result: confirm before proceeding.

## Step 2: Gather Context

**Preflight:**

1. Confirm clean working tree (`git status --porcelain`). Do not discard changes.
2. Fetch PR metadata (title, body, base, head, commits, files, checks).
3. Check out the PR locally:
   - Prefer: `gh pr checkout <PR_NUMBER>`
   - If checkout fails due to diverged local branch: fetch fresh (`git fetch origin <headRefName>:pr-<PR_NUMBER> && git checkout pr-<PR_NUMBER>`) or delete the stale local branch.
4. Collect:
   - PR details: `gh pr view <PR_NUMBER>`
   - Full diff: `gh pr diff <PR_NUMBER>`
   - Checks: `gh pr checks <PR_NUMBER>`
   - Issue comments: `gh pr view <PR_NUMBER> --json comments`
   - Review comments: `gh api repos/{owner}/{repo}/pulls/{pr_number}/comments`
   - (`{owner}/{repo}` via `gh repo view --json nameWithOwner -q .nameWithOwner`)

**Scope hygiene:** Review the PR diff, not local merge artifacts. Compare against the base ref explicitly if needed (`git diff origin/<baseRefName>...HEAD`). Do not start servers unless asked.

## Step 3: Audit the Changes

Complete a thorough audit **before writing the review document**. Do not present findings incrementally. Use parallel subagents or exploratory mode to speed up the audit — e.g., one agent reading the diff while another explores related files, or multiple agents investigating different areas of the codebase simultaneously.

Minimum audit:

- Read PR description and all commit messages.
- Check CI status; note missing signal (no tests, skipped jobs).
- Review the full diff to map what changed.
- Read the most important touched files in full (not just the diff hunks) to understand behavior in context and avoid diff tunnel vision.
<!-- @> Explore related files — callers, callees, types, tests. Diff alone is rarely enough context -->
- **Explore related files** — callers, callees, shared types, tests, adjacent modules. The diff alone is rarely enough context. Trace imports, follow function calls, and read the surrounding code that interacts with the changed code.
- For any new dependencies: check maintenance status, look for existing alternatives in the codebase.
<!-- @> Prove claims in code. No speculative "likely/may" — back every claim with a specific code path or reproduction -->
- When making factual claims, **prove them in code**. No speculative "likely/may" — every claim must be backed by a specific code path, user flow, or reproduction scenario. If you identify a potential issue, trace it to a concrete situation where it actually manifests in this codebase. If you can't construct a real reproduction path, it's not a real issue.

## Step 4: Write the Review Document

Write the document to a file. Ask me where I'd like it saved, or default to `.context/pr-<NUMBER>-review.md`.

The document has five sections, progressing from high-level understanding down to specific details — enabling the reader to move up and down the ladder of abstraction.

---

### Section 1: Summary

One paragraph. What does this PR do, and why? What problem does it solve? What constraints or tradeoffs shaped the approach?

### Section 2: Conceptual Changes

The middle of the abstraction ladder. Explain what shifted architecturally, structurally, or conceptually:

- New or changed mental models, dataflow, control flow
- Core invariants and assumptions the code now relies on
- New APIs, data structures, types, schemas
- New dependencies or libraries
- Configuration changes, migrations, breaking changes
- How this affects the rest of the codebase

Use diagrams (mermaid or ASCII) when they clarify relationships or flows.

### Section 3: Change Walkthrough

The bottom of the ladder. Walk through the actual changes comprehensively — the goal is that after reading this section, I understand every change in the PR.

**Grouping:** Organize changes by logical theme, not strictly file-by-file. When multiple files follow the same pattern (e.g., "added error handling to all API routes"), describe the pattern once with one or two concrete examples and list the remaining files. For unique or complex changes, go file-by-file.

**For each change or group of changes:**

- Explain what changed and why
- Include code snippets showing the relevant lines (both before and after when the diff matters)
- Reference specific files and line numbers: `path/to/file.ts:42`
- When behavior changed, trace through a concrete scenario step-by-step showing the old behavior vs. the new behavior

**Links:** For every file/line reference, provide two clickable links:

- **Local** — workspace-root-relative path with `#L` fragment: `/path/to/file.ts#L42`
- **GitHub** — PR file view: `https://github.com/{owner}/{repo}/pull/{number}/files#diff-{sha}R{line}`

Format as: `path/to/file.ts:42` ([local](/path/to/file.ts#L42) | [github](https://github.com/...))

Generate GitHub links from `gh api` data when available. Always pair links with inline code snippets so the document is self-contained even without clicking.

### Section 4: Issues

A table of all potential issues, followed by detailed write-ups.

**Issues table:**

| ID  | File         | Line | Issue                            | Importance | Confidence |
| --- | ------------ | ---- | -------------------------------- | ---------- | ---------- |
| R1  | `src/foo.ts` | 42   | Missing null check on user input | Critical   | High       |
| R2  | `src/bar.ts` | 15   | Redundant database query         | Medium     | Medium     |

**Importance levels:**

- **Critical** — blocks merge; correctness bug, data loss, security issue
- **High** — likely bug or regression that should be fixed before merge
- **Medium** — should fix; meaningful improvement to correctness, UX, or maintainability
- **Low** — minor improvement; better but not urgent
- **Nit** — style, naming, or preference

**Confidence levels:**

- **High** — verified in code; the issue demonstrably exists
- **Medium** — strong evidence but haven't fully traced all paths; could be mitigated by something not yet checked
- **Low** — pattern looks suspicious but may be intentional or handled elsewhere

**Detailed write-ups:** After the table, expand each issue with its own subsection headed by the ID:

#### R1: Missing null check on user input

**`src/foo.ts:42`** · Critical · High confidence

```ts
// src/foo.ts:40-45
function processUser(input: UserInput) {
  const name = input.user.name; // ← input.user could be undefined
  return normalize(name);
}
```

Explain the problem concretely. Trace through the scenario that triggers it:

1. `processUser()` is called from `handleRequest()` at `src/api.ts:28`
2. `input.user` is only populated when auth succeeds, but this path is also reachable from the public endpoint at `src/routes.ts:15`
3. → `TypeError: Cannot read properties of undefined`

**Suggested fix:**

```ts
function processUser(input: UserInput) {
  if (!input.user) {
    throw new InvalidInputError("user is required");
  }
  const name = input.user.name;
  return normalize(name);
}
```

The categories of issues to look for:

- **Bugs**: correctness errors, logic mistakes, race conditions, unhandled edge cases
- **UX problems**: confusing behavior, missing feedback, poor error messages
- **UI changes**: any modifications to components, CSS, HTML, styling (Ark, Panda, design tokens, etc.), or UI semantics — **always call these out** even if there are no glaring issues, so they can be reviewed against design standards. Flag patterns that might warrant new persistent rules.
- **Code simplification**: unnecessary complexity, dead code, over-abstraction
- **Refactoring opportunities**: duplicated logic, poor naming, structural improvements
- **Performance**: unnecessary work, N+1 queries, missing memoization
- **Security**: injection, auth bypass, data exposure
- **Test gaps**: missing coverage for new behavior, untested edge cases

**Proving issues are real:** Every issue above Nit importance must include a concrete reproduction path — a specific user flow, API call sequence, or code path that demonstrates the problem actually occurs in practice. Walk through the steps: what the user does, what function gets called, what state leads to the failure. If you cannot construct a plausible scenario where the issue manifests in this actual codebase, downgrade to Nit or remove it.

Be comprehensive but pragmatic. Do not pad the list with theoretical problems to appear thorough.

### Section 5: Alternative Approaches

For PRs that introduce meaningful new logic, architecture, or patterns, include a section that asks: **"If we wrote this from scratch with the same goal, how could we do it differently?"**

This is not a critique of the PR — it's a design exploration. Consider:

- Simpler abstractions that achieve the same result
- Different architectural patterns (e.g., push vs. pull, eager vs. lazy, server vs. client)
- Ways to reduce the surface area of the change
- Opportunities to leverage existing infrastructure that the PR doesn't use
- Tradeoffs the current approach makes and what the alternatives trade instead

Keep it grounded and specific — reference the actual code and constraints. This section is optional for small or straightforward PRs.

---

## Step 5: Present and Iterate

After writing the document, tell me:

- Where the file is saved
- A brief summary (5-10 lines): what the PR does, how many issues found at each importance level, and any critical items

Then I will:

- Read the document and leave inline comments referencing issue IDs (e.g., "R3: I think this is intentional because...")
- Ask questions in chat about specific changes or issues
- Request you expand, update, or add sections
- Ask for deeper analysis of specific areas

When I reference an issue ID or section, respond in whatever medium is appropriate:

- **Questions / discussion**: answer in chat
- **Requests to expand or add detail**: update the document
- **Disagreements on issues**: discuss in chat, then update the issue's status/write-up in the document if the conclusion changes

You **must not** submit reviews or post comments on GitHub via CLI/API. I handle that manually.

## Document Maintenance

The review document is a living artifact. As the review progresses:

- Issues may be resolved, downgraded, or removed — update the table accordingly
- New issues may surface from discussion — add them with the next available ID
- Sections may need expansion based on my questions
- If the PR is updated with new commits, re-audit the changes and update affected sections

Keep the document as the single source of truth for the review state.
