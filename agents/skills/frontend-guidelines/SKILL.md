---
name: frontend-guidelines
description: Semantic HTML, modern CSS, and frontend markup best practices. Use when writing, reviewing, or refactoring HTML, CSS, or templating markup. Triggers on .html/.css files, layout and spacing questions, flexbox/grid patterns, color systems, accessibility/a11y, semantic elements, responsive design, CSS custom properties, or styling architecture decisions.
global_category: HTML/CSS
---

# Frontend Guidelines

Core rules are compiled into GLOBAL.md. This skill contains additional detail.

<!-- @> Semantic elements over div/span; built-in elements over generic containers -->
## Semantic HTML First

Prefer built-in semantic elements over generic containers:

- Structure: `article`, `header`, `main`, `nav`, `section`, `ul/li`
- Interactive: `button`, `form`, `label`
- Content: `table`, `time`

Avoid `div`/`span` unless necessary. Prefer screen-reader text with proper structure over ARIA-only solutions.

## Modern CSS Patterns

<!-- @> Flexbox/grid + gap; margin is code smell. Logical properties (block/inline, start/end). Transform sub-properties -->
### Layout

- Use flexbox/grid with `gap`
- Use of `margin` is a code smell. In most cases you should prefer setting `padding` on a container element or using `gap` properties to control spacing and layout. Margins break encapsulation and make components less modular.
- Prefer logical properties: `block`/`inline`, `start`/`end` over `left`/`right` and `top`/`bottom`.
- Use transform sub-properties: `translate`, `rotate`, `scale` rather than a single `transform` property.

<!-- @> Colors: tokens/custom properties, then oklch or hex (not rgb) -->
### Colors

- Use tokens/custom properties when available
- Otherwise: `oklch` or hex (not rgb)
- Note: "Tokens" and CSS custom properties are interchangeable terms

<!-- @> CSS over JS when equivalent -->
## CSS Over JavaScript

Prefer CSS for behavior over JavaScript solutions when both achieve the same result.

<!-- @> srOnly over aria-label. focus-visible on all interactive elements, never outline-none without replacement. dvw/dvh over vw/vh -->
## Accessibility

- Prefer `srOnly` text over `aria-label` duplication — screen readers get richer context from real DOM text.
- Custom interactive elements (`div` with `onClick`) need keyboard handlers for Enter and Space.
- All interactive elements need visible focus indicators via `focus-visible`. Never apply `outline-none` without a replacement. Prefer `:focus-visible` over `:focus`.
- Use `dvw`/`dvh` over `vw`/`vh` — more reliable on mobile (accounts for browser chrome).

## Images

- Always include explicit `width` and `height` to prevent Cumulative Layout Shift.
- Use `loading="lazy"` for below-fold images; `priority`/`fetchpriority="high"` for critical above-fold images.

## Tips

- `maskImage` for gradient fades — works regardless of background color.
- Icons: fix missing `viewBox` at the SVG source, not at every usage site.

## References

- [PandaCSS patterns](references/pandacss.md) — boxSize, colorPalette, token(), data attributes, icon styling
- [Ark UI patterns](references/ark-ui.md) — RadioGroups, component conventions
- [Web Interface Guidelines](references/web-interface-guidelines.md) — Vercel's comprehensive UI checklist (forms, typography, touch, performance, dark mode)
