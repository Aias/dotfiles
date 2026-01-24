# Drizzle ORM Beta Changelog Research

Drizzle publishes beta versions with commit-hash suffixes (e.g., `1.0.0-beta.11-fc31a5f`). These require special handling since they don't follow standard semver and aren't always documented in GitHub releases.

## Version Format

Beta versions follow this pattern:
```
1.0.0-beta.{N}-{commit_hash}
```

Multiple builds may exist for each beta number (e.g., `beta.11-fc31a5f`, `beta.11-88ca292`). The `beta` npm tag points to the latest.

## Finding Available Versions

1. **Check npm dist-tags** for the latest beta:
   ```bash
   npm view drizzle-orm@beta version
   ```

2. **List all beta versions** to find what's between current and latest:
   ```bash
   npm view drizzle-orm versions --json | jq -r '.[]' | grep -E '^1\.0\.0-beta\.(1[0-9]|[2-9][0-9])'
   ```

3. **Check npm dist-tags** for branch/feature tags:
   ```bash
   npm view drizzle-orm dist-tags --json
   ```

## Finding Changelogs

GitHub releases often lag behind npm publishes. Use these sources:

1. **GitHub Releases** (may be outdated):
   - https://github.com/drizzle-team/drizzle-orm/releases
   - Filter for pre-releases tagged `v1.0.0-beta.*`

2. **Compare commits** between versions:
   ```
   https://github.com/drizzle-team/drizzle-orm/compare/{old_hash}...{new_hash}
   ```
   Example: `https://github.com/drizzle-team/drizzle-orm/compare/fc31a5f...a5629fb`

3. **Pull requests** for beta releases:
   - Search PRs with title containing "beta" or the version number
   - Example: https://github.com/drizzle-team/drizzle-orm/pull/5277 (Beta.12)

4. **Official docs** (often delayed):
   - https://orm.drizzle.team/docs/latest-releases

## Related Packages

Always update these together (they share version numbers):
- `drizzle-orm`
- `drizzle-kit`
- `drizzle-zod`

Check all three in both root and workspace packages.

## Update Commands

```bash
# Using bun
bun update drizzle-orm@beta drizzle-kit@beta drizzle-zod@beta

# Or specify exact version
bun add drizzle-orm@1.0.0-beta.12-a5629fb drizzle-kit@1.0.0-beta.12-a5629fb drizzle-zod@1.0.0-beta.12-a5629fb
```

## Common Changes in Beta Releases

Beta releases typically include:
- Effect integration fixes (`@effect/sql-pg`)
- Query builder improvements (RQB v2)
- drizzle-kit fixes for `generate`, `push`, `pull` commands
- Type system improvements
- Cache handling fixes
- Migrator updates
