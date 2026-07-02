---
name: dig
description: >-
  Use when the user invokes /dig or asks you to dig into, investigate, or get to
  the bottom of a bug, behavior, regression, or question about how something
  works. Also use when the user says "why is this happening", "trace this",
  "figure this out", "root cause", or expresses frustration that a previous
  investigation was too shallow. Forces exhaustive, evidence-backed investigation
  using every available tool before returning an answer.
global_category: Investigation
---

# Dig

<!-- @> Verified answer, not plausible hypothesis. Every claim must cite a specific line, commit, log entry, or data point you read -->
Exhaustive, read-only investigation mode. The goal is a **verified answer**, not a plausible hypothesis. Every claim in your conclusion must point to a specific line of code, commit, log entry, or data point that you personally read during this investigation.

## Mindset

You are an investigator, not a consultant. Consultants offer possibilities; investigators deliver findings. The difference is evidence.

- **Assume the answer is findable.** If you have tools that could resolve an uncertainty, use them before speaking. The user invoked `/dig` because they want depth, not speed.
- **Follow the trail wherever it goes.** Cross repo boundaries. Read into `node_modules`. Open the backend. Check the database schema. Read the PR that introduced the code. The answer is often one hop past where a normal investigation would stop.
<!-- @> Cross repo boundaries: read node_modules, the backend, schema, PRs, git blame — the answer is often one hop past where a normal investigation stops -->
- **No open conditionals.** If your conclusion would contain "if X works this way" or "depending on whether Y", that conditional is your next research task, not something to present to the user. Resolve it, then conclude.

## Scope: read-only, but resourceful

This skill is strictly investigative — do not modify application code, push commits, or mutate production data. However, you are free to create and run **temporary tools** to aid the investigation: one-off scripts to parse logs, query a database, transform data for analysis, test a hypothesis, or reproduce a condition. Treat these as disposable instrumentation, not deliverables.

## What to investigate (and in what order)

Start from the reported symptom and work backward toward the cause. At each step, prefer primary sources over inference.

### 1. Understand the problem

Read the user's description carefully. If the problem statement itself is ambiguous — you genuinely don't know what behavior they're describing or what "wrong" means — ask a clarifying question. This is the **only** acceptable reason to ask a question. Never ask questions that are really "should I bother checking X?" in disguise.

### 2. Read the code

- **Trace the full data flow** from input to output. Don't stop at the function that looks relevant — read its callers, its callees, the types it operates on, and the data it queries.
- **Cross repo boundaries.** If the frontend calls a backend API, read the backend resolver. If a library is involved, read the library source (locally in `node_modules` or via the repo on GitHub).
- **Read the types and schema.** GraphQL schemas, Prisma models, TypeScript types — these are contracts. Mismatches between what code sends and what the other side expects are a top-5 bug category.

### 3. Read the history

- `git log` and `git blame` on the files involved. Look for recent changes that could have introduced or changed the behavior.
- Read the **full diff** of suspicious commits, not just the summary. Commit messages lie; diffs don't.
- Read related **PRs** — the description, the discussion, and the review comments. Use `gh pr view` and `gh api` to pull this information.
- Check if the relevant code was recently refactored, moved, or had its dependencies changed.

### 4. Query the data

When the bug could be a data issue rather than a code issue, look at the actual data:

- **Database**: If you have read access (local dev database, read replica, database MCP), query for the specific records involved. Check whether the data matches what the code expects — missing foreign keys, null columns that shouldn't be null, stale values, failed migrations.
- **GraphQL / APIs**: Run read-only queries against available endpoints to see what the application actually returns for the inputs in question.
- **Write throwaway scripts** if needed — a quick SQL query, a Node one-liner to decode a value, a script to check the shape of an API response. These are investigation tools, not production code.

### 5. Check external systems

Use every MCP and tool available:

- **Linear**: Search for related tickets. Check if the bug has been reported before, if there's ongoing work that touches the same area, or if there are linked issues with additional context.
- **Sentry**: Search for errors matching the symptom. Look at stack traces, breadcrumbs, and event frequency. Check whether the error started at a specific deployment.
- **GitHub**: Read related PRs, issues, and discussions. Check CI/CD logs if relevant.
- **Browser tools**: If the bug is frontend and you have browser MCP access, reproduce it — take screenshots, inspect network requests, check console errors.

### 6. Read external library source

When a bug might involve library behavior:

- Read the relevant source code in `node_modules/` or fetch it from GitHub.
- Check the library's changelog, release notes, or migration guide for the installed version.
- Search the library's GitHub issues for similar reports.

<!-- @> Verify premises of every option before presenting (no false dichotomies). Sanity-check counts/percentages from subagent or tool output before reporting; reconcile against a second source -->
### 7. Verify, don't speculate

Before presenting a conclusion:

- **Can you point to the exact line(s) of code?** If not, keep looking.
- **Have you confirmed your theory against the actual data flow?** Walk through the code path with concrete values.
- **Have you ruled out the obvious alternatives?** The first plausible theory is often wrong. Spend time on the second and third most likely causes before committing to one.
- **Is the premise of every option you're about to present actually true?** A false dichotomy is worse than no recommendation. If two options reduce to the same thing, say so. If an option assumes a capability the library/API/schema doesn't have, drop it. Confirm against primary sources before framing the choice.
- **Have you sanity-checked counts, totals, and percentages?** Numbers passed through from subagent reports or tool output are routinely off (double-counted, decimal misplaced, scoped to the wrong directory). Reconcile against a second source — or scan the underlying data directly — before reporting. If a count looks implausibly high or low for the size of the system, flag the implausibility as part of the answer.
<!-- @> Suspected regression: reproduce against the baseline (origin/<base>) before blaming the diff. Verify the real artifact, not a proxy — built bundle over source listing, rendered DOM over component tree, resolved path over import string. Re-run an implausible "nothing found" before trusting it. Report impact at true severity; data loss is not a display issue -->
- **For a suspected regression, is the fault new here or pre-existing?** Before blaming the change in front of you, reproduce against the baseline — check out `origin/<base>`, or read the code as it stood before the diff. A fault that reproduces on the baseline is latent, not introduced; saying "this PR broke it" when the bug predates the branch sends the fix to the wrong place.
- **Did you verify the real artifact, not a proxy for it?** A source file's presence is not proof it ships — read the built bundle to confirm what survived tree-shaking. A component in the tree is not proof of what renders — inspect the actual DOM (computed opacity, mounted nodes, applied classes). An import string is not proof of what loads — resolve the path. Assert from the thing itself, not from a listing, a config, or a happy-path repro that skips the failing input.
- **Did a "nothing found" result get a second look?** An empty query result is only evidence if the query was sound. When absence is surprising — no matching tickets, no logs, no rows where you expected some — assume the query is wrong before concluding the thing doesn't exist. Loosen the filter, widen the time window, or check spelling/casing, then re-run.
- **Did you characterize impact at its true severity?** State what actually happened, not the most reassuring framing. Silent data loss, a wrong write, or a security exposure is not a "display issue" because the surface looks calm. Read far enough to know whether information was lost or merely hidden, and report the worse finding when both are live.

## Questions: when to ask, when not to

**Ask** when you genuinely cannot understand what the user is describing:

- "When you say '[ambiguous term or question],' do you mean [clarification X] or the [clarification Y]?"
- "Is this happening [on X] or [on Y]?"

**Don't ask** when the question is really about whether you should do more work:

- ~~"Would you like me to check the backend code?"~~ Just check it.
- ~~"Should I look at the git history?"~~ Just look at it.
- ~~"Do you want me to trace this into the SDK?"~~ Just trace it.

If in doubt, investigate first. You can always share what you found. You can't un-waste the user's time waiting for permission to do obvious next steps.

## How to present findings

Lead with the answer. Then show the evidence.

```
[Root cause — one or two sentences]

[Evidence chain — the specific code paths, commits, or data points that prove it]

[If relevant: what to do about it]
```

Don't narrate your investigation process unless the user asks. They want the finding, not the journey.

If after exhausting all available sources you genuinely cannot determine the root cause, say so plainly — state what you checked, what you ruled out, and what remains unknown. But be honest with yourself about whether you actually exhausted your tools. "It's likely a data issue that requires checking the production database" is not a valid conclusion if you have database access you haven't used. The only acceptable unknowns are ones gated by access you genuinely don't have.
