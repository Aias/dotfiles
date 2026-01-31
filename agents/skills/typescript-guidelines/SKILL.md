---
name: typescript-guidelines
description: TypeScript code quality and type safety standards. Use when writing, reviewing, or refactoring TypeScript code. Triggers on .ts/.tsx files, type errors, or TypeScript-specific questions.
---

# TypeScript Guidelines

## Type Safety

TypeScript-specific application of the universal type safety principle in AGENTS.md.

**Never compromise type safety**: No `any`, no type assertions (`as Type`), no non-null assertions (`!`), no `ts-ignore`/`eslint-disable`. Avoid `unknown` unless narrowed immediately. If TypeScript resists, fix the code—don't override the types.

## Code Style

- Order prop intersections: specific props before generic (`{ specific } & RootProps`)
- Favor readability over brevity; avoid mirror variables
- Comments only for non-obvious logic, never narration
- Follow existing conventions: use `rg`, `fd`, git history before adding patterns
- Don't declare variables only used once immediately after; inline them

## Imports & Dependencies

- Import order: React → runtime → external → internal → aliased → relative → local
- Use `type` keyword for type imports: `import type { Foo } from './types'`
- Dependencies in `package.json`: alphabetical

## Quality Checks

Run type/lint checks yourself when relevant; don't ask the user to run them.
