---
name: changelog
description: >
  Assess dependency release notes and migration impact for requested package upgrades
  or an outdated-dependency audit. Apply updates only when the user requests them.
compatibility: Requires the project's package manager and network access.
---

# Dependency changes

Start with the packages and version range the user named. For an outdated-dependency audit, detect the package manager from `packageManager` and the lockfile (`bun.lock`, `bun.lockb`, `pnpm-lock.yaml`, `yarn.lock`, or `package-lock.json`). Run [the detection helper](scripts/detect-outdated.sh) from the project being assessed. Rush projects use `rush-pnpm outdated` inside the relevant package.

Read official release notes, migration guides, or source changes for the relevant version range. Prioritize breaking changes and changes that affect the codebase's actual usage. Include patch releases when requested or when their fixes matter to the task. For Drizzle prereleases, read [the version-specific guidance](references/drizzle-beta.md).

Trace affected APIs into the codebase before reporting migration work. Distinguish changes that require action from optional capabilities. Delegate independent package research when the scope warrants it, then validate the combined conclusions.

Report the current and target versions, relevant changes, affected behavior, and recommended update order. Link the primary sources. Preserve requested exclusions and account for coupled versions or peer dependencies.

A request to assess an upgrade ends with the assessment. A request to apply it authorizes the scoped dependency and code changes. Follow the repository's pinning policy, use its package manager to regenerate lockfiles, and run the relevant checks. Do not expand a named-package update into an all-dependency update.
