---
name: frontend-html-css-guidelines
description: Semantic HTML and modern CSS best practices. Use when writing, reviewing, or refactoring frontend HTML/CSS. Triggers on .html/.css files, styling questions, or accessibility discussions.
---

# Frontend HTML/CSS Guidelines

## Semantic HTML First

Prefer built-in semantic elements over generic containers:

- Structure: `article`, `header`, `main`, `nav`, `section`, `ul/li`
- Interactive: `button`, `form`, `label`
- Content: `table`, `time`

Avoid `div`/`span` unless necessary. Prefer screen-reader text with proper structure over ARIA-only solutions.

## Modern CSS Patterns

### Layout

- Use flexbox/grid with `gap`
- Use of `margin` is a code smell. In most cases you should prefer setting `padding` on a container element or using `gap` properties to control spacing and layout. Margins break encapsulation and make components less modular.
- Prefer logical properties: `block`/`inline`, `start`/`end` over `left`/`right` and `top`/`bottom`.
- Use transform sub-properties: `translate`, `rotate`, `scale` rather than a single `transform` property.

### Colors

- Use tokens/custom properties when available
- Otherwise: `oklch` or hex (not rgb)
- Note: "Tokens" and CSS custom properties are interchangeable terms

## CSS Over JavaScript

Prefer CSS for behavior over JavaScript solutions when both achieve the same result.
