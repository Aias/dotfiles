---
name: react-guidelines
description: React component patterns and anti-patterns. Use when writing, reviewing, or refactoring React components. Triggers on .jsx/.tsx files, React hooks, or component questions.
---

# React Guidelines

- In addition to these skills reference the `/vercel-react-best-practices` skill for more detailed guidance.
- When dealing with `useEffect`, reference the `remove-effects` skill for guidance.

## Modern React Patterns

- **React auto-forwards refs** (v19+): do not use `forwardRef`
- **Avoid `useEffect`**: Read [You Might Not Need an Effect](https://raw.githubusercontent.com/reactjs/react.dev/main/src/content/learn/you-might-not-need-an-effect.md) before adding one, or use the `remove-effects` skill
- Attempt to remove existing `useEffect`s where possible

## Timing & Performance

- Prefer `requestAnimationFrame` (single or double) or `useLayoutEffect` over `setTimeout` for timing
- Render repeated elements via iteration (`map`, etc.) instead of manual duplication

## Styling

Keep inline styles rare. Use `as React.CSSProperties` only when unavoidable (e.g., view-transition names or CSS variables). Avoid other type casting.
