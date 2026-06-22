# REVIEW Mode

Read-only fan-out across a change-set. Output: numbered findings in chat.

## Standing rules (override all defaults)

These are non-negotiable. The user has codified them repeatedly across hundreds of sessions, including as standing preferences attached to Conductor review requests.

- **Read-only.** No code edits, no commits, no GitHub or Linear comments unless explicitly authorized in this turn. Output is chat text only.
- **No `AskUserQuestion` during the review.** Complete the review without user intervention; questions go in the report's "open questions" section.
<!-- @> Verify, don't punt — and verify the invariant, not just the symptom. Anything verifiable must be resolved by the reviewer using library source, docs, web search, RFCs, git history, issues/PRs. If a finding rests on "X is true today," confirm X. For multi-site compliance, enumerate per-site status in the finding -->
- **Verify, don't punt — and verify the invariant, not just the symptom.** Anything verifiable during the review must be verified by the reviewer — not asked back to the user. That includes reading library source code (locally in `node_modules` or upstream on GitHub), official docs, framework release notes, RFCs, GitHub issues/PRs, and the project's own git history. Web search and validation against public documentation are first-class tools for every subagent in the fan-out. Findings of the form *"this might be wrong, can you confirm?"* are not findings — they're questions the reviewer was supposed to resolve.

  Extend the same rule to the invariant a finding rests on. If your claim is *"X is the case today,"* X is itself a verification step — confirm it by reading the code, not by intuition. A dedup proposal that assumes *"selected always equals the most recent"* must read the path that produces "selected." A nullability claim must read the schema. For compliance findings across multiple call sites, enumerate which sites already comply and which don't, in the finding itself — don't lump them.
- **Cite file path + line range on every finding.** A claim without a citation is a question you should have answered yourself. For claims grounded in external sources, cite the URL (docs page, library file, release note) too.
- **Never restate the diff.** Don't include lines of code or states already obvious from the GitHub UI. Findings only.
<!-- @> Name the impact, not just the mechanism. Every bug finding states what the operator/end-user observes. Security findings include a concrete attack walkthrough (API call + inputs + what the attacker gains beyond legitimate access) and a `blocker` vs `defense-in-depth` tag -->
- **Name the impact, not just the mechanism.** A finding that says *"this Bull queue retries the failure notification"* is half a finding. The other half is what the operator or end-user observes: *"three persistent ChatEvent rows in conversation history, three response cycles, customer sees 'I'm having trouble' turns before the retry succeeds."* Without the impact line, the reader can't tell whether to block.

  For security findings specifically: include a concrete attack walkthrough — the API call, the inputs, the caller's permissions, and **what the attacker accomplishes beyond what their legitimate access already grants them.** Tag the finding `blocker` (the attacker gains capability they don't have) or `defense-in-depth` (the attacker can already do the equivalent legitimately; the fix is hygiene/audit-trail integrity). A `defense-in-depth` security finding is Medium, not High.
<!-- @> Recommend the fix, don't menu it. One recommended fix per finding; alternatives go in prose. Before suggesting removal of incomplete code, read the diff's intent — broken-because-unfinished is not the same as broken-because-buggy -->
- **Recommend the fix, don't menu it.** GLOBAL.md's *"recommend, don't menu"* rule applies inside findings too. One recommended fix per finding. Alternatives belong in prose (*"if the queue API exposes an exhausted-retries hook, prefer that; otherwise gate on `attemptsMade`"*), not in bulleted A/B options that push the choice back to the reader.

  Before suggesting *removal* of incomplete code, read the diff's intent. **Broken-because-unfinished** is not the same as **broken-because-buggy**: a not-yet-wired feature should be wired up, not amputated. The fix has to come from what the author was trying to do, not from the assumption that the broken piece should go away.
- **Numbered list with stable IDs** (`#1`, `#2`, ...). The user replies with positional refs ("fix 2, 3, 5", "walk me through #1"). Aggregated prose loses this affordance.
- **HIGH SIGNAL ONLY.** False positives erode trust faster than missed issues. See [Explicit false positives](#explicit-false-positives).

## Phase 1: Establish scope

Pick the diff source in this order, and **state which you used** as the first line of the report:

1. **Conductor workspace** — `mcp__conductor__GetWorkspaceDiff` with `stat: true` first, then specific files. Read attached `Review request.md` if present.
2. **Open PR** — `gh pr view --json files,baseRefName`, then `gh pr diff`.
3. **Branch vs base** — resolve base via Conductor target → existing PR → repo convention → ask. Then `git fetch origin <base>` (local refs go stale), then `git diff origin/<base>...HEAD` (three-dot — `..` is symmetric and pulls in unrelated merged work).
4. **Staged / uncommitted** — `git diff --staged` and `git diff HEAD`.
5. **Recently modified files** — only files the user named, or that you edited earlier in this conversation.

Read the PR title and description (not the changes) for author intent. Read any AGENTS.md / CLAUDE.md files in directories the diff touches — these define what counts as a finding.

Never diff `dev...main` or any other long-lived-base-to-base range. It pulls in unrelated merged work.

## Phase 2: Fan-out

For any non-trivial diff, **always fan out across parallel subagents.** Single-pass review is the dominant failure mode the user pushes back on (*"there's no way you reviewed all 17k lines of that code"*). Parallel agents are also strongly preferred over hand-written codemods or scripted refactors.

Launch agents in a single message so they run concurrently. Each agent gets the full diff (or its bucket) plus the PR title and description for author intent.

### Code-judo lens

Frame every axis around **deleting complexity, not rearranging it.** A clean review doesn't just spot bugs — it looks for restructurings that preserve behavior while making the implementation dramatically simpler, smaller, more direct.

- Prefer the solution that **makes the code feel inevitable in hindsight.**
- Don't settle for *"a merely cleaner version of the same messy idea"* if there's a path to a much simpler idea.
- Flag refactors that *"move code around but fail to reduce the number of concepts a reader must hold in their head."*
- Don't approve merely because behavior is correct. *"It works"* isn't enough if the codebase is messier afterward.

This is the lens, not an axis. Apply it inside each subagent below.

### Standard axes (default to all four)

**Axis 1: Bug scan.**
Look for obvious bugs in the diff itself — incorrect logic, broken control flow, off-by-ones, missing awaits, mishandled errors. Focus on the diff; don't reach outside it for context unless the finding requires it. Flag only significant bugs that will cause incorrect behavior at runtime.

**Axis 2: AGENTS.md / CLAUDE.md compliance.**
Audit the diff for compliance with AGENTS.md / CLAUDE.md rules. When evaluating compliance for a file, only consider AGENTS.md / CLAUDE.md files that share a path with the file or its parents. Quote the exact rule being broken; if you can't quote it, don't flag it.

<!-- @> Axis 3 also flags unexplained scope creep: net-new functionality with no traceable origin (not on the base, not in the PR description, not tied to the task) and no deliberate reason. Reachable code is still suspect — recommend reverting it, don't assume intent -->
**Axis 3: Dead code, duplication & unexplained scope.**
Look for code introduced by the diff that is unused, unreachable, or duplicates existing code. Also look for **uncovered dead code** — code elsewhere that became unused because of this diff (utilities only the removed feature called, design tokens it used, GraphQL fields it queried, fixtures it referenced). Cross repo boundaries when relevant (acorn ↔ chestnut for full-stack work).

Flag **unexplained scope creep** even when the code is reachable: a behavior, flag, or branch the diff adds that isn't on the base, isn't called for by the PR description or the task, and has no deliberate reason you can trace. A query gaining an extra filter parameter, or a handler sprouting a mode nobody asked for, reads as accidental — recommend reverting it rather than assuming the author meant it. Unrelated cosmetic churn dragged in by a focused edit (an import reorder, a sweeping reformat) belongs in the same bucket: recommend excluding it from the diff, leaving the split-into-its-own-commit alternative to prose. Read the PR description and `git blame` the surrounding lines before flagging — if the addition traces to stated intent, it's in scope.

Don't flag intentional scaffolding: re-export barrels, design-system primitives, framework-required exports. If unsure whether something is dead vs. scaffolding, ask in the open-questions section.

**Axis 4: LOC & structural simplification.**
Categorize the diff into **generated / boilerplate / moved / new logic**. Then flag:

LOC & diff shape:
- Total LOC when the new-logic fraction is small relative to total diff (e.g. 20k-line dependency bump that could use a maintainer codemod).
- Splits / extractions that don't reduce LOC.
- Any file the diff pushes from below 1000 lines to above. This is a hard rule — see [the 1000-line ceiling](#the-1000-line-ceiling).

Code judo (deleting complexity, not rearranging):
- Implementations where a cleaner reframing could delete whole categories of complexity — modes, conditionals, helper layers, branches.
- Refactors that move code around but fail to reduce the number of concepts a reader has to hold.
- Special-case logic that should become a simpler default flow with fewer exceptions.

Spaghetti growth:
- New ad-hoc conditionals, scattered special cases, or one-off branches inserted into unrelated flows.
- *"Weird if statements in random places"* — treat as design problem, not a stylistic nit.
- One-off booleans, nullable modes, or flags that complicate existing control flow.
- Narrow edge-case handling jammed into the middle of an already busy function.

Thin abstractions & magic:
- Wrappers, identity abstractions, or pass-through helpers that add indirection without buying clarity.
- Generic "magic" mechanisms that hide simple data-shape assumptions.
- Bespoke helpers when the codebase already has a canonical utility for the job.

Boundary & layer leaks:
- Feature-specific logic leaking into general-purpose modules.
- Implementation details leaking through APIs.
- Logic added in the wrong package or layer when there's a clear canonical home.
- Casts, `any`, `unknown`, or unnecessary optionality that paper over an unclear invariant the boundary should make explicit.

Duplicated work & orchestration:
- New code that duplicates an existing utility.
- New parameters added to a function instead of generalizing existing ones.
- Stringly-typed code where an enum / branded type / union already exists.
- Unnecessary work: redundant computation, N+1, repeated file reads.
- Sequential async flow where obviously independent work could run in parallel.
- Partial-update logic that leaves state less atomic than necessary.

### The 1000-line ceiling

<!-- @> Hard rule: don't let a PR push any file from below 1000 lines to above. Only waivable when the file is extremely repetitive/uniform (a data table, generated code, a flat enum) where any split would hurt readability. Default: decompose first -->

A PR may not push any file from below 1000 lines to above. This is a hard rule, not a soft signal.

The only valid waiver: the file's content is extremely simple and uniform — a long data table, generated code, a flat enum, a list of route registrations — where any decomposition would hurt readability rather than help it. If the file has meaningful control flow, multiple concerns, or distinct sections, decompose first. Don't waive because "it's a lot of work to split" or "the new code logically belongs here". When in doubt: decompose.

When the diff crosses this line, the finding should propose the decomposition (subcomponents, helpers, separate modules) rather than just naming the violation.

### Custom axes

Add or substitute axes when the user names a concern: *"focus on app router patterns"*, *"review for false positive conversions"*, *"only the changes about storybook"*, *"is X used anywhere?"*. Replace one of the standard axes; don't pile on.

## Phase 3: Validation

For each finding from Phase 2, launch a validator subagent that **confirms with code citation** before the finding goes into the report. Single-axis agents over-flag; the validator's only job is to refute or confirm.

Pass the validator: the PR title/description, the finding description, and the rule (if compliance). Its job is to read the cited code and answer: *is this actually a problem, given the surrounding context the original agent didn't see?*

Filter out anything the validator didn't confirm. Track confirmation count per axis — if Axis N had 12 findings but only 2 survived validation, the axis prompt likely needs tightening (this is signal for skill iteration, not for the report).

## Phase 4: Report

Output format — copy this shape exactly.

```
Scope: <one line: "this branch vs origin/dev", "PR #1234", "workspace diff (Conductor)", "staged changes">

### #1 <Short title>

<One paragraph: what the issue is, why it matters. Cite the file and line. Don't paste large snippets — short inline excerpts only when needed to make the finding readable.>

File: path/to/file.ts:42-48

### #2 <Short title>

...

---

Verdict: <one of: "pass", "pass with conditions: <which>", "restructure needed: <why>">
Next: <one of: "pick items to apply", "run `/pr-guidelines` to refresh the description", "defer to follow-up PR", "no action needed">

Open questions:
- <Anything that needed a judgment call you couldn't make alone>
```

Rules for the format:

- Titles are short and noun-shaped, not narration. ("Empty input crashes form", not "I found a bug where if the input is empty…")
- One paragraph per finding. Two only if the issue genuinely needs more.
- `File:` lines use the workspace-relative path. Line numbers via `:start-end` (rendered display) or `#Lstart` for clickable links — pick whichever the project uses.
- No headers per finding beyond `### #N`. The user has accepted this format and references findings by number.
- Group findings by axis only when there are many (>10). Otherwise, a flat numbered list reads better.

### Finding prioritization

When there are many findings, order them by severity, not by axis. Higher-priority items appear first as `#1`, `#2`, etc.:

1. **Structural code-quality regressions** — the diff makes the codebase materially harder to work with.
2. **Missed code-judo opportunities** — a dramatic simplification is visible and the diff didn't take it.
3. **Spaghetti growth** — new branching tangled into unrelated flows.
4. **Boundary / abstraction / type-contract problems** — leaked layers, thin wrappers, magic.
5. **File-size and decomposition concerns** — 1000-line rule, missed splits.
6. **Modularity and abstraction issues** — duplication, parameter sprawl, missing extractions.
7. **Legibility and maintainability concerns** — naming, structure within a function, comment policy.

Prefer a smaller number of high-conviction findings over a long list of cosmetic notes.

### Verdict line

A one-line pass/fail at the bottom, before `Next:`. Pick one:

- **`pass`** — no structural regression, no missed simplification, no boundary leak. APPLY phase is optional cleanup.
- **`pass with conditions: <which>`** — the diff is acceptable if specific items are addressed. List the item numbers (e.g. *"pass with conditions: fix #1, #3, #5"*).
- **`restructure needed: <why>`** — the diff has a presumptive blocker. The author needs to reframe before merge. State which blocker triggered it.

Treat these as **presumptive blockers** for `restructure needed`:

- A code-judo move would delete substantial complexity that this diff preserves.
- The diff pushes a file from below 1000 lines to above without a valid waiver.
- New ad-hoc branching makes an existing flow more tangled.
- Feature checks scattered across shared code where a dedicated abstraction would isolate them.
- An unnecessary wrapper, cast-heavy contract, or magic mechanism makes the design more indirect.
- An existing canonical helper is duplicated, or logic landed in the wrong layer.

End with a **Next** line — one of: pick items to apply, refresh PR description, defer, no action. Don't propose verbose alternatives; recommend the one that fits.

## Explicit false positives

Do not flag any of these. They erode the signal-to-noise ratio.

- **Pre-existing issues** — only flag what the diff introduced or worsened.
- **Linter-catchable issues** — assume the linter runs; don't duplicate it. (Do not run the linter yourself to verify.)
- **Pedantic nitpicks** a senior engineer wouldn't flag.
- **General code-quality concerns** (test coverage, generic security worries) unless explicitly required by AGENTS.md / CLAUDE.md.
- **Issues silenced explicitly in code** (lint-ignore comments, `// known issue`) — the author already decided.
- **Intentional scaffolding** — design-system primitives, re-export barrels, framework-required exports.
- **Repetition that serves an argument** — callbacks, deliberate restatement, layered comments. Only flag *fully duplicated / redundant* sections.
- **Specific semantic intent** — `<dialog>` for top-layer behavior, `<a download>` for download semantics, `useId` for SSR-stable IDs. Read the intent before flattening.
- **Test files when the diff is non-test** unless the test file itself has a bug.
- **Style suggestions** not explicitly required by AGENTS.md / CLAUDE.md.

If you're not certain an issue is real, drop it.

## When the diff is for someone else's branch

If the user is reviewing a teammate's branch (*"this is all orkhan, we're just reviewing his branch"*, *"compare this branch against lakshita's most recent updates"*):

- APPLY is **hard-gated off**. Even an explicit-looking "fix it" should be confirmed before editing someone else's branch.
- Read prior reviews and the teammate's responses. Report what was fixed/addressed vs what remains.
- The framing of the report shifts: not *"problems I introduced"* but *"things to discuss before merge"*.
- Author intent matters more — read the PR description and any Slack/comment context the user references (*"what does cooper mean by this?"*) before flagging.

## Re-review

When the user asks for re-review after they applied feedback (*"re-review, I consolidated some pages"*, *"the other agent just finished, review those first"*):

- `git fetch` first. Other agents may have pushed to the same base.
- Read the diff since the prior review (use commit ranges or `gh pr view --comments` for prior threads).
- The report structure changes: enumerate prior findings, then state for each whether it was fixed, addressed differently, or remains. Add new findings only after the status pass.

## Conductor specifics

When inside a Conductor workspace (paths under `~/conductor/workspaces/...`, `CONDUCTOR_*` env vars):

- Use `mcp__conductor__GetWorkspaceDiff` instead of `git diff`. Start with `stat: true` to scope the read; request specific files in follow-up calls.
- The target branch from the system instruction is the diff base — not the checked-out branch name.
- Other workspaces may push to the same base; `git fetch` before any cross-workspace comparison.
- If the user attached `.context/attachments/.../Review request.md`, read it for any workspace-specific overrides (it usually reiterates: read-only, chat output, no GitHub comments).
- `mcp__conductor__DiffComment` is **hard-gated**. Never post inline comments without an explicit "post these as comments" from the user in this turn.

## Tools the user reaches for

In rough order of how often they appear in past sessions:

- **Parallel subagents** — the canonical answer to "did you actually read it". Use them by default.
- **`gh pr diff`, `gh pr view --json files,baseRefName`** — PR-context REVIEW.
- **`git diff origin/<base>...HEAD`** (three-dot, after fetch) — branch-vs-base REVIEW.
- **`mcp__conductor__GetWorkspaceDiff`** — Conductor REVIEW.
- **`knip`** — sometimes invoked by name for dead-code discovery. Useful post-migration ("leftover from migration X to Y"). Don't trust it blindly — scaffolding files are common false positives.
- **`similarity-ts`** — mentioned for duplicate detection beyond knip. Same caveat.
- **`/orient`** — often precedes a review when the user hasn't said what branch/base they're on.
- **`/dig`** — for "why does this happen" style questions buried inside a review.

Conspicuously not used: `eslint --fix`, hand-written codemods, throwaway scripts. The user prefers parallel subagents over scripted refactors.
