---
name: react-guidelines
description: React component patterns, anti-patterns, and effect management. Use when writing, reviewing, or refactoring React components. Triggers on .jsx/.tsx files, React hooks, or component questions.
---

# React Guidelines

Reference the `vercel-react-best-practices` skill for detailed performance optimization patterns.

## Modern React Patterns

- **React auto-forwards refs** (v19+): do not use `forwardRef`
- **Avoid `useEffect`**: Effects are an escape hatch for synchronizing with external systems—they should NOT be used for data transformation, event handling, or state derivation. If code runs in response to a user action, it belongs in an event handler—not an Effect. If you are writing or editing code that uses `useEffect`, you _must_ read `references/you-might-not-need-an-effect.md` to understand the valid uses and confirm the proposed usage is correct.

## Timing & Performance

- Prefer `requestAnimationFrame` (single or double) or `useLayoutEffect` over `setTimeout` for timing
- Render repeated elements via iteration (`map`, etc.) instead of manual duplication

## Styling

Keep inline styles rare. Use `as React.CSSProperties` only when unavoidable (e.g., view-transition names or CSS variables). Avoid other type casting.
