---
name: changelog
description: Analyze outdated dependencies and summarize changelogs
compatibility: Requires npm, pnpm, yarn, or bun, plus network access.
---

You are helping me review outdated dependencies and understand what has changed. Follow this workflow:

### Step 1: Detect Package Manager and Check Outdated Dependencies

Run the helper script to detect the package manager and list outdated
dependencies:

```bash
scripts/detect-outdated.sh
```

**Rush monorepos:** If you detect a `rush.json` at the repo root, use `rush-pnpm outdated` instead. This command must be run from within a specific project directory (where `package.json` exists), not from the repo root.

### Step 2: Filter for Changelog Research

From the outdated output, identify packages with:

- **Major version bumps** (e.g., 5.1.4 → 6.0.1)
- **Minor version bumps** (e.g., 11.7.2 → 11.8.0)

**Patch-only updates** (e.g., 1.27.3 → 1.27.4) are excluded from changelog research by default since they typically contain only bug fixes without breaking changes. However, they will still be included in the final package updates (see Step 6).

**Special packages:** Some packages require different research approaches:

- **Drizzle beta versions** (e.g., `drizzle-orm@1.0.0-beta.*`): See [references/drizzle-beta.md](references/drizzle-beta.md) for how to find changelogs and compare versions.

Present the filtered list (major/minor only) and then proceed to changelog research. All major and minor updates are researched by default unless otherwise specified.

### Step 3: Research Changelogs in Parallel

For each package with a minor or major update, spawn a parallel subagent/subtask to research the changelog. Each subagent should:

1. **Find the best changelog source** by checking (in order of preference):
   - GitHub releases page: `https://github.com/{owner}/{repo}/releases`
   - CHANGELOG.md in the repo root
   - RELEASES.md or HISTORY.md in the repo
   - Official documentation site changelog (e.g., `docs.example.com/changelog`)
   - npm package page changelog tab

2. **Extract relevant changes** between the current and latest versions:
   - Breaking changes (for major updates)
   - New features and APIs
   - Deprecations
   - Bug fixes that might affect our usage
   - Migration guides (for major updates)

3. **Return a structured summary**:

   ```
   Package: {name}
   Update: {current} → {latest}
   Type: Major|Minor

   Changes:
   - [feature] Description
   - [breaking] Description
   - [deprecation] Description
   - [fix] Description

   Migration Notes: (if applicable)
   ```

### Step 4: Analyze Codebase Impact

After gathering all changelogs, analyze the current codebase to identify:

1. **Breaking change impacts**: Search for usages of deprecated or removed APIs
2. **New feature opportunities**: Identify places where new features could:
   - Simplify existing code
   - Fix existing workarounds or hacks
   - Improve performance or type safety
3. **Bug fix relevance**: Check if any fixed bugs might have been affecting us

For each package, spawn a subagent to:

```
Search the codebase for usages of {package} and cross-reference with the changelog.
Identify:
- Any code that uses deprecated/removed APIs
- Patterns that could be simplified with new features
- Workarounds that might no longer be needed
```

### Step 5: Generate Report

Present a final report with:

**Summary Table**
| Package | Current | Latest | Type | Impact |
|---------|---------|--------|------|--------|
| name | x.y.z | a.b.c | Major/Minor | High/Medium/Low/None |

**Detailed Findings**

For each package:

- Changelog summary
- Codebase impact assessment
- Recommended actions (if any)
- Files that may need changes

**Recommended Update Order**

If there are dependencies between packages (e.g., @trpc/\* packages), recommend the order to update them.

### Output Format

Present findings incrementally as subagents complete. Wait for my confirmation before:

- Actually updating any packages
- Making any code changes
- Creating migration PRs

Do NOT run any update commands unless I explicitly request it.

### Step 6: Apply Updates

When the user requests updates, include all outdated packages (major, minor, AND patch) without asking. Only exclude packages if the user:

- Requests only specific packages be updated
- Asks to update only the researched packages

When updating, run all updates in a single command where possible (e.g., `pnpm update pkg1 pkg2 pkg3`) rather than individually.
