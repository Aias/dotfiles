# Web Interface Guidelines

Condensed from Vercel's [Web Interface Guidelines](https://github.com/vercel-labs/web-interface-guidelines). For the full checklist, fetch the latest:

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

## Forms

- Inputs need `autocomplete`, `name`, and appropriate `type` (`email`, `tel`, `url`, `number`) and/or `inputmode` (`email`, `tel`, `url`, `numeric`).
- Never block paste.
- Labels must be clickable via `htmlFor`.
- `spellCheck={false}` on emails/codes.
- Submit buttons remain enabled until request starts.
- Display errors inline; focus first error on submit.
- Guard unsaved changes with `beforeunload`.

## Typography

- Ellipsis character `…` not `...`.
- Curly quotes `" "` not straight quotes.
- Non-breaking spaces in measurements (`10&nbsp;MB`) and keyboard shortcuts.
- `font-variant-numeric: tabular-nums` for number columns.

## Content Handling

- Text containers must handle overflow: `truncate`, `line-clamp-*`, or `break-words`.
- Flex children need `min-w-0` for text truncation.
- Handle empty states gracefully.

## Performance

- Virtualize lists exceeding ~50 items.
- Avoid layout reads during render; batch DOM operations.
- Prefer uncontrolled inputs where possible.
- `<link rel="preconnect">` for CDN domains; preload critical fonts.

## Navigation & State

- URL should reflect application state (filters, tabs, pagination).
- Use `<a>`/`<Link>` for proper click handling.
- Deep-link stateful UI.
- Require confirmation for destructive actions.

## Touch & Interaction

- `touch-action: manipulation` to eliminate 300ms tap delay.
- `overscroll-behavior: contain` in modals/drawers.
- `autoFocus` sparingly — desktop primary inputs only.

## Safe Areas & Layout

- Full-bleed layouts need `env(safe-area-inset-*)`.
- Prevent unwanted scrollbars via `overflow-x-hidden`.

## Dark Mode

- `color-scheme: dark` on `<html>`.
- Match `<meta name="theme-color">` to background.
- Explicitly style native `<select>` elements.

## Hydration

- Inputs with `value` require `onChange`; otherwise use `defaultValue`.
- Guard date/time rendering against server-client mismatches.

## Hover States

- Buttons and links need `hover:` states.
- Interactive states should increase contrast over default.
