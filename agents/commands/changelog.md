---
name: changelog
description: Analyze outdated dependencies and summarize changelogs
---

You are helping me review outdated dependencies and understand what has changed. Follow this workflow:

### Step 1: Detect Package Manager and Check Outdated Dependencies

Detect the package manager by checking for lock files in order of preference:

```bash
if [ -f "bun.lock" ] || [ -f "bun.lockb" ]; then
  bun outdated
elif [ -f "pnpm-lock.yaml" ]; then
  pnpm outdated
elif [ -f "yarn.lock" ]; then
  yarn outdated
elif [ -f "package-lock.json" ]; then
  npm outdated
else
  echo "No recognized lock file found"
fi
```

### Step 2: Filter to Minor and Major Updates

From the outdated output, identify packages with:

- **Major version bumps** (e.g., 5.1.4 → 6.0.1)
- **Minor version bumps** (e.g., 11.7.2 → 11.8.0)

Exclude patch-only updates (e.g., 1.27.3 → 1.27.4) unless they contain security fixes.

Present the filtered list to me before proceeding.

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
