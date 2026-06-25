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
<!-- @> Confidence-gated reporting: default-drop anything you can't confirm; the lone exception is the high-impact tail (data loss/security/silent corruption) — surface it tagged with what's unverified, never inflate its priority to compensate -->
- **Confidence-gated reporting.** Default to dropping anything you can't confirm is real. The single exception is the high-impact tail: a finding you couldn't fully verify but whose potential cost is severe — data loss, a security hole, silent corruption — is worth surfacing, explicitly tagged with what remains unverified and why you couldn't resolve it in this pass. Never inflate such a finding's priority to compensate for the uncertainty; report it at its true confidence with the gap named. Low-confidence *and* low-impact: drop without mention.

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

**Model tier: every review and validator subagent runs on the latest Opus at high or extra-high effort** — a judgment call per axis (reach for extra-high on the densest buckets, high is fine for the rest); max is never needed. The analysis quality is the constraint, not tokens or latency — a weaker model that misses the bug or the simplification costs more than it saved. Reserve faster models only for narrow retrieval fan-out (collecting files, grepping call sites) whose raw output an Opus agent then reasons over.

### Code-judo lens

Frame every axis around **deleting complexity, not rearranging it.** A clean review doesn't just spot bugs — it looks for restructurings that preserve behavior while making the implementation dramatically simpler, smaller, more direct.

- Prefer the solution that **makes the code feel inevitable in hindsight.**
- Don't settle for *"a merely cleaner version of the same messy idea"* if there's a path to a much simpler idea.
- Flag refactors that *"move code around but fail to reduce the number of concepts a reader must hold in their head."*
- Don't approve merely because behavior is correct. *"It works"* isn't enough if the codebase is messier afterward.

This is the lens, not an axis. Apply it inside each subagent below.

### Standard axes (default to all four; add Axis 5 when an originating spec exists)

All axes — including spec conformance — launch together in one message and run **in parallel**. Spec conformance is special only at synthesis: its findings are read *first* and used to set the disposition of every other axis's findings (see [Synthesis](#synthesis-let-spec-conformance-set-disposition)), not to gate the other agents.

**Axis 1: Bug scan.**
Look for obvious bugs in the diff itself — incorrect logic, broken control flow, off-by-ones, missing awaits, mishandled errors. Focus on the diff; don't reach outside it for context unless the finding requires it. Flag only significant bugs that will cause incorrect behavior at runtime.

**Axis 2: AGENTS.md / CLAUDE.md compliance.**
Audit the diff for compliance with AGENTS.md / CLAUDE.md rules. When evaluating compliance for a file, only consider AGENTS.md / CLAUDE.md files that share a path with the file or its parents. Quote the exact rule being broken; if you can't quote it, don't flag it.

<!-- @> Axis 3 also flags unexplained scope creep: net-new functionality with no traceable origin (not on the base, not in the PR description, not tied to the task) and no deliberate reason. Reachable code is still suspect — recommend reverting it, don't assume intent -->
**Axis 3: Dead code, duplication & unexplained scope.**
Look for code introduced by the diff that is unused, unreachable, or duplicates existing code. Also look for **uncovered dead code** — code elsewhere that became unused because of this diff (utilities only the removed feature called, design tokens it used, GraphQL fields it queried, fixtures it referenced). Cross repo boundaries when relevant (acorn ↔ chestnut for full-stack work).

<!-- @> Dedup/dead-code: search scope is broader than finding scope. Scan the whole module (jscpd/similarity-ts), not just changed files — a new helper re-implementing an existing util is diff-introduced duplication even though its twin is untouched. Keep only findings where the diff is one side; drop pre-existing dup between two untouched files -->
**Search scope is broader than finding scope.** To catch a new helper that re-implements an existing utility — or existing code the diff just orphaned — detection must range over the whole module/package, not only the changed files. A function the diff adds that already exists elsewhere is diff-**introduced** duplication even though its twin sits in an untouched file, so it's in scope; pre-existing duplication between two files the diff never touched is a [pre-existing issue](#explicit-false-positives), not a finding. Run `jscpd` / `similarity-ts` against the package, then keep only findings where the diff is one side of the duplication. `knip` is already whole-project, so it covers the dead-code-elsewhere direction on its own.

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

<!-- @> Axis 5 (spec conformance, only when a ticket/PRD/RFC exists): report missing/partial, wrong, and unrequested behavior vs the spec. Runs in parallel but is consumed first at synthesis to set disposition — unrequested code gets removed, not polished. Skip and note "no spec available" rather than inventing requirements -->
**Axis 5: Spec conformance (only when an originating spec exists).**
Runs only when the change traces to a written spec — a Linear/GitHub issue, a PRD, an RFC, a kickoff or design doc. Resolve the spec in this order: issue references in the commit messages or PR description (`PROJ-123`, `Closes #45`) → a spec path the user named → a PRD/RFC under `docs/`, `specs/`, or the ticket linked on the PR. If none of these resolve, **skip this axis and note "no spec available"** — never invent requirements to grade against.

Give the agent the resolved spec plus the diff, and have it report three finding classes, quoting the spec line for each:
- **Missing / partial** — a requirement the spec asks for that the diff doesn't implement, or implements only partway.
- **Wrong** — a requirement the diff appears to implement, but the implementation doesn't satisfy what the spec actually asked for.
- **Unrequested** — behavior the diff adds that the spec never called for. This overlaps Axis 3's scope-creep detection, approached from the requirements side rather than the structural side; let synthesis dedup (Axis 5 holds the authoritative spec; Axis 3 still catches creep when there's no spec to check against).

This axis is **load-bearing for disposition, not just another finding source** — its output reframes how every other finding is judged at synthesis.

### The 1000-line ceiling

<!-- @> Hard rule: don't let a PR push any file from below 1000 lines to above. Only waivable when the file is extremely repetitive/uniform (a data table, generated code, a flat enum) where any split would hurt readability. Default: decompose first -->

A PR may not push any file from below 1000 lines to above. This is a hard rule, not a soft signal.

The only valid waiver: the file's content is extremely simple and uniform — a long data table, generated code, a flat enum, a list of route registrations — where any decomposition would hurt readability rather than help it. If the file has meaningful control flow, multiple concerns, or distinct sections, decompose first. Don't waive because "it's a lot of work to split" or "the new code logically belongs here". When in doubt: decompose.

When the diff crosses this line, the finding should propose the decomposition (subcomponents, helpers, separate modules) rather than just naming the violation.

### Custom axes

Add or substitute axes when the user names a concern: *"focus on app router patterns"*, *"review for false positive conversions"*, *"only the changes about storybook"*, *"is X used anywhere?"*. Replace one of the standard axes; don't pile on.

## Phase 3: Validation

<!-- @> Phase 3 validator is adversarial: its job is to REFUTE each finding (defaulting to refuted when unsure), so a finding survives only if it can't be broken with a code citation. Exception: a refuted-but-high-impact finding carries forward tagged with the doubt -->
For each finding from Phase 2, launch a validator subagent whose job is to **refute the finding**, not to confirm it. Single-axis agents over-flag, so the validator starts adversarial: assume the finding is a false positive and try to break it by reading the cited code and the surrounding context the original agent didn't see. A finding survives only if the validator *cannot* refute it with a code citation; when the validator is unsure, it defaults to refuted.

Pass the validator: the PR title/description, the finding description, and the rule (if compliance). It reads the cited code and answers: *can I show this is not actually a problem here?*

Filter out everything the validator refuted, **with one exception**: a refuted-but-high-impact finding (data loss, security, silent corruption) carries forward into the report tagged with the validator's doubt, per [confidence-gated reporting](#standing-rules-override-all-defaults). Don't silently drop a severe finding just because it couldn't be fully nailed down. Track refutation count per axis — if Axis N produced 12 findings but only 2 survived, the axis prompt likely needs tightening (signal for skill iteration, not for the report).

## Synthesis: let spec conformance set disposition

Before writing the report, reconcile the axes against each other — this is where parallel findings become a coherent verdict, and where Axis 5 earns its keep. Read the spec-conformance findings *first*, then re-judge every other finding through them:

- A finding on code the spec axis marks **unrequested** flips from *"fix / simplify it"* to *"remove it, or justify why it stays"* — don't recommend polishing code that hasn't earned its place.
- A **missing / partial** spec finding outranks cosmetic findings on code that *is* present; a diff that's clean but incomplete still fails.
- A **wrong** spec finding and a bug-scan finding on the same code are the same problem from two angles — merge them, don't double-report.

When no spec axis ran, synthesis is just cross-axis dedup. The disposition reframing only applies when there's a spec to judge against.

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
<!-- @> Don't flag behavior the diff deliberately changes: a removed gate or broadened value chosen on purpose is not a regression. Confirm intent against the PR description/spec; flag only an unweighed blast radius the author plausibly missed -->
- **Behavior the diff deliberately changes.** When the PR's stated purpose is to remove, loosen, or replace a behavior, don't flag that removal as a regression — it's the point of the change. Confirm the intent against the PR description or the originating spec, then flag only if the deliberate change has a blast radius the author plausibly didn't weigh (e.g. dropping a guard also exposes an unrelated path). A hardcoded-broad value or removed gate chosen on purpose is an intentional change, not a bug.

If you're not certain an issue is real, drop it — unless its potential impact is high (data loss, security, silent corruption), in which case surface it tagged with what's unverified, per [confidence-gated reporting](#standing-rules-override-all-defaults).

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
**Static-analysis seeds — leads, never findings.** These surface candidates fast; none is authoritative. Every hit is confirmed by reading the actual code and call sites before it becomes a finding — the verify-don't-punt and [confidence-gated reporting](#standing-rules-override-all-defaults) rules apply to tool output too. Newer tools (deslop, react-doctor) over-flag; lean on the verification step.

Run them with **`bunx`** (fast, and confirmed to leave the reviewed repo's lockfile / `package.json` / working tree untouched — it caches globally, not in cwd); `npx` is the fallback where bun isn't installed.

Point the duplication/dead-code scanners at the **whole package the diff touches, not just the changed files** — a new helper that duplicates an existing utility, or code the diff orphaned, lives outside the diff. Then filter findings to those the diff caused (Axis 3's search-broad-report-narrow rule).

- **`bunx deslop-cli --json`** — the **broad first pass for JS/TS.** One scan covers dead code, redundant types/exports/constants, identity wrappers, simplifiable expressions, copy-paste blocks, unnecessary type assertions / `@ts-ignore`, circular imports, and cyclomatic/cognitive complexity — seeding Axes 3, 4, and type-safety together. It tags each finding high/medium/low; map those straight onto confidence-gated reporting (default-drop low unless the impact is high).
- **`bunx react-doctor@latest`** — React-specific audit (state & effects, performance, architecture, security, a11y) across Next/Vite/RN/Expo. Read-only; can report only newly-introduced issues against a PR. Seeds the React/frontend slice of a review and pairs with [`/react-best-practices`](../react-best-practices/SKILL.md), [`/avoid-effects`](../avoid-effects/SKILL.md), and the HTML/CSS section.
- **Focused supplements when one axis needs depth:** `bunx knip` (dead files/exports/deps — strong post-migration, but scaffolding is a common false positive), `similarity-ts` (AST-based duplication), `bunx jscpd` (token-based, language-agnostic duplication).
- **`rg` / `fd` / `git grep`** — the verification workhorses: confirm a symbol is truly unused, trace call sites, check for orphaned utilities/tokens/fixtures. Reach for these to *confirm* every lead above rather than trusting any tool's report.
- **`/orient`** — often precedes a review when the user hasn't said what branch/base they're on.
- **`/dig`** — for "why does this happen" style questions buried inside a review.

Conspicuously not used: `eslint --fix`, hand-written codemods, throwaway scripts. The user prefers parallel subagents over scripted refactors.
