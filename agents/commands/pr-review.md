You are helping me review a pull request. Follow this workflow:

### Step 1: Find Relevant PRs

If I specify a PR number in the initial prompt, use that PR number and skip directly to step 2. Otherwise, find open PRs where I am assigned, requested as a reviewer, or have already submitted a review:

```bash
gh pr list \
  --search "is:open (review-requested:@me OR reviewed-by:@me OR assignee:@me)" \
  --limit 10 \
  --json number,title,author,reviewRequests,assignees,createdAt \
  --jq '.[] | {number, title, author: .author.login, reviewers: [.reviewRequests[]?.login], assignees: [.assignees[]?.login], created: .createdAt}'
```

If there are multiple PRs, ask which one I want to review. Present the results to me as a numbered list for me to choose from. If there's only one, confirm before proceeding.

### Step 2: Check Out and Examine the PR

Once I confirm the PR:

1. Check out the PR locally: `gh pr checkout <PR_NUMBER>`
2. Get PR details: `gh pr view <PR_NUMBER>`
3. Get the full diff against the base branch: `gh pr diff <PR_NUMBER>`
4. Check for existing comments:

   - Issue comments (general PR discussion): `gh pr view <PR_NUMBER> --json comments`
   - Review comments (inline code comments): `gh api repos/{owner}/{repo}/pulls/{pr_number}/comments`

   Note: `{owner}/{repo}` can be found via `gh repo view --json nameWithOwner -q .nameWithOwner`

### Step 3: Analyze the Changes

Examine the diff and provide:

**High-Level Summary**

- What is the overall purpose of this PR?
- New APIs introduced (endpoints, functions, methods)
- New or modified data structures (types, interfaces, schemas)
- New dependencies or libraries added
- Architectural or design pattern changes
- Configuration changes
- Database migrations or schema changes
- Any breaking changes

**Dependency Check**

- For any new dependencies: check if they are actively maintained
- Flag archived, deprecated, or unmaintained libraries
- Look for existing libraries in the codebase that could be used instead (check imports across the codebase)

**Impact Assessment**

- How does this affect existing code?
- What areas of the codebase will need to be aware of these changes?
- Are there documentation implications?

### Step 4: Review Focus Areas

Provide a numbered list of files or directories to review, in logical order (foundational changes first, then core logic, then usages, then tests). For each item, briefly note what to focus on:

- API or DB schema design considerations, if any
- Complex logic that needs careful examination
- Potential edge cases or error handling gaps
- Design system usage patterns, new components, and styling conventions
- Performance considerations
- Security implications
- Test coverage gaps
- Code style or consistency issues

### Step 5: Suggested Comments

Prepare a list of suggested review comments. For each comment:

- Keep it short and to the point
- Use a friendly, suggestion-based tone (e.g., "Consider...", "Might be worth...", "Nit: ...")
- Only be strongly opinionated if there's an obvious bug or issue
- Include the file path and line number
- **Verify line numbers** by reading the actual file content before suggesting

Format each suggestion as:

```
File: <path>
Line: <number>
Comment: <your suggestion>
```

Separate each suggestion with a horizontal rule with newlines before and after.

### Output Format

Present your findings in sections, then wait for my feedback. I will:

- Ask you to modify suggestions
- Tell you which comments to keep/remove
- Request changes to the review approach

Do NOT submit any reviews or comments until I explicitly approve the plan.
