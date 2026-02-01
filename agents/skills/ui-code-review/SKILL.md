---
name: ui-code-review
description: >-
  Review UI/frontend code for style nits and best practices. Use when reviewing
  PRs with React, PandaCSS, CSS, or HTML changes. Complements general PR review
  with specific UI patterns.
compatibility: Requires GitHub CLI (gh). Optimized for React 19 + PandaCSS + Ark UI codebases.
---

# UI Code Review

Focused review for UI/frontend code patterns. Run after or alongside general PR review to catch style nits and best practices specific to React, PandaCSS, CSS, and HTML.

## Step 1: Determine PR

If a PR number is provided, use it. Otherwise:

```bash
# Check if current branch has an open PR
gh pr view --json number,title,headRefName 2>/dev/null
```

If no PR exists for the current branch, ask the user which PR to review.

## Step 2: Get Changed Files

```bash
gh pr diff <PR_NUMBER> --name-only | grep -E '\.(tsx?|css|scss)$'
```

Focus only on UI-related files (`.tsx`, `.ts` with JSX, `.css`, `.scss`).

## Step 3: Review Against Checklist

For each changed file, check against the rules below. Present findings as a table:

| File | Line | Issue | Rule |
|------|------|-------|------|
| `src/Component.tsx` | 42 | `width: '24px', height: '24px'` | Use `boxSize` |

Only flag issues that appear in the **changed lines** of the PR diff, not pre-existing code.

---

## Review Rules

### PandaCSS

**boxSize for equal dimensions**
```diff
- width: '24px', height: '24px'
+ boxSize: '24px'
```

**Logical properties**
```diff
- top: '10px', right: '10px', paddingLeft: '12px'
+ insetBlockStart: '10px', insetInlineEnd: '10px', paddingInlineStart: '12px'
```

**data-palette + colorPalette for dynamic colors**
```diff
- css={{ backgroundColor: palette === 'red' ? 'red.500' : 'blue.500' }}
+ data-palette={palette} css={{ backgroundColor: 'colorPalette.main' }}
```

**token() for inline styles**
```diff
- style={{ boxShadow: 'var(--shadows-canvas)' }}
+ style={{ boxShadow: token('shadows.canvas') }}
```

**_childIcon for icon styling**
```diff
- <Icon size={16} color="gray.500" />
+ <styled.span css={{ _childIcon: { boxSize: '4', color: 'gray.500' } }}><Icon /></styled.span>
```

**Data attributes for conditional styles**
```diff
- css={{ color: isActive ? 'blue' : 'gray' }}
+ data-active={isActive} css={{ color: 'gray', _active: { color: 'blue' } }}
```

**No margin in reusable components** — parent controls spacing via gap/padding.

**Use existing tokens** — check if a token exists before using escape hatches.

**dvw/dvh over vw/vh** — more reliable on mobile.

**maskImage for gradient fades** — works regardless of background color.

---

### React

**No React.FC**
```diff
- const Component: React.FC<Props> = (props) => { ... }
+ const Component = ({ prop1, prop2 }: Props) => { ... }
```

**No forwardRef** — React 19 auto-forwards refs.

**satisfies over as**
```diff
- const config = { ... } as Config
+ const config = { ... } satisfies Config
```

**Proper type guards without casts**
```diff
- if (TYPES.includes(x as SomeType)) { ... }
+ const TYPES: ReadonlySet<string> = new Set(['A', 'B']);
+ if (TYPES.has(x)) { ... }
```

**Complete dependency arrays** — missing deps cause stale closures.

**requestAnimationFrame over setTimeout** — for DOM timing.

**useForm({ values }) over useEffect** — for form value sync.

**Ark UI RadioGroups** — for mutually exclusive menu options (better a11y).

---

### HTML / Accessibility

**Semantic elements** — `article`, `figure`, `section`, `button` over generic `div`.

**srOnly over aria-label duplication**
```diff
- <div aria-label={`Message from ${sender}: ${text}`}>
+ <div><span className={srOnly}>{sender}:</span> {text}</div>
```

**Keyboard handlers for interactive divs** — handle Enter and Space if using onClick.

---

### Icons

**Size via CSS, not props**
```diff
- <ChevronIcon size={16} />
+ <styled.span css={{ _childIcon: { boxSize: '4' } }}><ChevronIcon /></styled.span>
```

**Fix at source** — if icon missing viewBox, fix SVG definition, not every usage.

---

### Code Quality

**Remove unused imports/variables** — dead code should be deleted.

**Fix typos** — in identifiers and strings.

**Clean up stale TODOs** — complete or remove.

**Types from GraphQL schema** — don't recreate types that exist in generated code.

**Empty string edge cases**
```diff
- const value = input ?? 'default'  // '' passes through
+ const value = input || 'default'
```

**No unnecessary optional chaining**
```diff
  if (!session) throw new Error('No session');
- session?.doThing();
+ session.doThing();
```

---

### Miscellaneous

**URLSearchParams truthiness**
```diff
- if (params.has('flag')) { ... }  // matches flag=false
+ if (params.get('flag') === 'true') { ... }
```

**Named booleans for multi-conditions**
```diff
- if (type === 'A' || type === 'B') { ... }
+ const playsSound = ['A', 'B'].includes(type);
+ if (playsSound) { ... }
```

**En dashes for ranges** — `1–10` not `1-10`.

**Array destructuring for hooks**
```diff
- const value = useHook()[0];
+ const [value] = useHook();
```

**Factor repeated conditions**
```diff
+ const isDisabled = !hasPermission || isLoading;
- <Field disabled={!hasPermission || isLoading} />
+ <Field disabled={isDisabled} />
```

---

## Output Format

Present findings grouped by category, then by file:

```
## PandaCSS Issues

**src/Component.tsx**
- Line 42: Use `boxSize: '24px'` instead of `width: '24px', height: '24px'`
- Line 58: Use logical property `paddingInlineStart` instead of `paddingLeft`

## React Issues

**src/hooks/useData.ts**
- Line 12: Missing `data` in useCallback dependency array
```

For each issue, include:
- File path and line number
- What to change (brief)
- The specific rule being applied

Skip categories with no issues. Keep suggestions concise — these are nits, not blockers.
