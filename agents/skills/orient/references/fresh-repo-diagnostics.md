# Fresh repo diagnostics

Use these only when the repo is genuinely unfamiliar — no `AGENTS.md`/`CLAUDE.md` context, no prior session memory, and the user hasn't explained the project. For a repo the agent already understands, skip this file; the commands are noisy and add little.

Adapted from [piechowski.io — Git Commands I Run Before Reading Any Code](https://piechowski.io/post/git-commands-before-reading-code/). The framing: commit history is a diagnostic picture of the project, and a few minutes of git archaeology tells you which code deserves attention first.

## 1. High-churn files

```bash
git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20
```

The 20 most-changed files in the past year. Churn predicts defects better than complexity alone — files at the top are usually the ones "people warn you about" and deserve attention before you pick random files to read.

## 2. Team composition

```bash
git shortlog -sn --no-merges
```

Contributors ranked by commit count. Reveals the bus factor: if one person wrote 60%+ of commits, their absence is a crisis. Pair with a recency filter to spot abandonment — the original author may have moved on.

**Caveat:** squash-merge workflows credit the merger, not the original writer, so on squash-heavy repos this understates authorship.

## 3. Bug clusters

```bash
git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20
```

Files with the most bug-related commits. Cross-reference with churn: files high on both lists are code that keeps breaking and keeps getting patched without being properly fixed.

**Caveat:** depends on commit message hygiene; noisy repos produce noisy results.

## 4. Project momentum

```bash
git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c
```

Commits per month across the repo's history. Shows whether the team is accelerating, declining, or batching into release cycles. Drops usually correlate with personnel change or disengagement — this is team data, not code data.

## 5. Firefighting patterns

```bash
git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback'
```

Frequency of reverts and emergency fixes. Regular reverts signal deploy fear and deeper systemic issues — unreliable tests, poor rollback procedures, or fragile architecture.

## How to use the output

Run these in parallel — the output is small and they don't depend on each other. In the orientation summary, surface only the one or two findings that change how you read the code ("top three churn files are all in `billing/`", "primary author hasn't committed in 8 months", "two reverts in the last month"). Do not paste the full top-20 lists into the summary; they're raw material for your own reading priorities, not output for the user.
