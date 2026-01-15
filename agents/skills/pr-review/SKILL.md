---
name: pr-review
description: Review a pull request
compatibility: Requires GitHub CLI (gh) and GitHub API access.
---

You are helping me review a pull request. Follow this workflow:

### Step 1: Find Relevant PRs

If I specify a PR number in the initial prompt, use that PR number and skip directly to step 2. Otherwise, find open PRs where I am assigned, requested as a reviewer, or have already submitted a review:

```bash
scripts/list-open-prs.sh
```

If there are multiple PRs, ask which one I want to review. Present the results to me as a numbered list for me to choose from. If there's only one, confirm before proceeding.

### Step 2: Check Out and Examine the PR

Once I confirm the PR:

**Preflight (before presenting anything):**

1. Confirm the working tree is clean (`git status --porcelain`). Do not discard user changes.
2. Fetch PR metadata first (title/body/base/head/commits/files/checks) so you know what you’re looking at.
3. Check out the PR locally:
   - Prefer: `gh pr checkout <PR_NUMBER>`
   - If checkout fails due to a diverged existing local branch, do **not** merge/rebase. Instead, create a fresh local branch tracking the remote head ref (e.g. `git fetch origin <headRefName>:pr-<PR_NUMBER> && git checkout pr-<PR_NUMBER>`), or delete the stale local branch if appropriate.
4. Collect review context:
   - PR details: `gh pr view <PR_NUMBER>`
   - Full diff: `gh pr diff <PR_NUMBER>`
   - Checks: `gh pr checks <PR_NUMBER>`
   - Existing comments:

   - Issue comments (general PR discussion): `gh pr view <PR_NUMBER> --json comments`
   - Review comments (inline code comments): `gh api repos/{owner}/{repo}/pulls/{pr_number}/comments`

   Note: `{owner}/{repo}` can be found via `gh repo view --json nameWithOwner -q .nameWithOwner`

**Scope hygiene:**

- Ensure you’re reviewing the actual PR diff, not incidental local merges. If needed, compare against the PR base ref explicitly (e.g. `git diff origin/<baseRefName>...HEAD --name-only`).
- Do not start servers or long-running processes as part of PR review unless I ask.

### Step 3: Analyze the Changes

Do a **comprehensive audit first**, then present findings. Do not present comments or conclusions until you have completed the audit.

Audit requirements (minimum):

- Read PR description + all commit headlines (and skim bodies if non-trivial).
- Verify checks status and note any missing signal (no tests, skipped jobs, etc.).
- Review the diff at a high level to understand what changed.
- Then read the most important touched files directly (not just the diff) to validate behavior and avoid “diff tunnel vision”.
- When you make a factual claim about behavior, **verify it** in code (or by showing the exact missing evidence). Avoid speculative language (“likely/may”) unless you explain exactly what is unknown and why.

Prioritize correctness and core runtime behavior over style nits. Then present the review to me in **two phases**:

#### Phase A (Pedagogical Overview — teach me the PR)

Before suggesting review comments, write an overview that helps me build the right mental model:

- What is the overall purpose of this PR, in one sentence?
- What problem(s) does it solve? What constraints drove the solution?
- What is the new conceptual model / architecture / dataflow? (How it works now.)
- What are the core invariants / assumptions the code relies on?
- What are the main risk areas or failure modes?
- Any new APIs introduced (endpoints, functions, methods)
- Any new or modified data structures (types, interfaces, schemas)
- Any new dependencies or libraries added
- Any architectural or design pattern changes
- Any configuration changes / migrations / breaking changes

#### Phase B (Interactive Review — one area at a time, one comment at a time)

Do **not** dump all review comments at once. Instead:

1. Propose a numbered **Review Order** (foundational first, then core logic, then usages, then tests).
2. Start with Review Order item #1 and suggest **one** potential review comment at a time.
3. Wait for me to respond (questions, followups, “skip”, or “next”) before continuing.
4. Continue until we exhaust the review order.

Interaction rules:

- If I say “skip” or “next”, move on immediately with no further persuasion.
- If I ask a runtime/behavior question mid-review, answer it clearly (with evidence), then resume the review order where we left off.

Important: I will manually add comments in GitHub. You **must not** submit reviews or post comments via CLI/API.

**Dependency Check**

- For any new dependencies: check if they are actively maintained
- Flag archived, deprecated, or unmaintained libraries
- Look for existing libraries in the codebase that could be used instead (check imports across the codebase)

**Impact Assessment**

- How does this affect existing code?
- What areas of the codebase will need to be aware of these changes?
- Are there documentation implications?

### Step 4: Review Focus Areas (build the Review Order)

Provide a numbered list of files or directories to review, in logical order (foundational changes first, then core logic, then usages, then tests). For each item, briefly note what to focus on:

- API or DB schema design considerations, if any
- Complex logic that needs careful examination
- Potential edge cases or error handling gaps
- Design system usage patterns, new components, and styling conventions
- Performance considerations
- Security implications
- Test coverage gaps
- Code style or consistency issues

### Step 5: Suggested Comments (interactive; one at a time)

When suggesting a review comment:

- Keep it short and to the point
- Use a friendly, suggestion-based tone (e.g., "Consider...", "Might be worth...", "Nit: ...")
- Only be strongly opinionated if there's an obvious bug or issue
- Include the file path and line number
- **Verify line numbers** by reading the actual file content before suggesting
- If the suggestion depends on “this used to work differently”, you must show the **actual old code** and the **new code** side-by-side (or as two clearly labeled snippets) so I can compare directly.
  - Use the PR base branch as “before” (e.g. `origin/dev`), and the checked-out PR branch as “after”.
  - Example “before” fetch: `git show origin/<baseRefName>:<path>`
  - Example “after” fetch: read the checked-out file content and cite the exact lines.

Format each suggestion as:

```md
**Location:** `<path>:<line_number>`
**Comment:** <your suggestion>
```

The code block above is just for formatting within these rules. Do not wrap the suggestions in code blocks. Separate each suggestion with a horizontal rule with newlines before and after.

### Output Format

Always present the review in two parts:

1. **Pedagogical Overview** (Phase A above)
2. **Interactive Review**: show the Review Order, then start with the first item and provide the first suggested comment.

Then wait for my feedback. I will:

- Ask you to modify suggestions
- Tell you which comments to keep/remove
- Request changes to the review approach

Do NOT submit any reviews or comments until I explicitly approve the plan.
