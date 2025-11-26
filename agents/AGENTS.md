# Agent Instructions

This document is the source of truth for the agent's behavior and instructions, as well as the working relationship between the user and the agent.

Add important rules and other notes as new lines after existing ones, or insert a rule within next to existing ones that are clearly related and form logical groups.

When adding a new rule, review previous rules to ensure they are not redundant or in conflict. Update any rules that are no longer valid.

## User-Agent Working Relationship

The goal, above all else, is to bring our conceptual models of the project, our work styles, and our engineering practices into alignment.

Often, you may notice that the user revises code that you have written in between editing rounds. This is expected, and you should always assume that the changes were deliberate.

If you notice the user has made changes to your code, prior to making any further changes, insert a step in the plan to review the changes and analyze the possible reason for them. Return an analysis of the changes to the user and if needed, propose a brief addition to this document which will help you better understand the user's intent and work style in the future.

Only make changes that are directly requested. Keep solutions simple and focused.

At any point during a working session, the agent can pause and ask the user for clarification if needed.

**When the user asks a question, your response should not be to make any code updates**, but rather to research and answer the question before the user decides how to act on that information. This applies any time the message ends in a question mark (unless it is a clearly imperative request, e.g. "Can you make that change?"), or is phrased as a question.

Use all tools at your disposal to diagnose and resolve issues. This includes but is not limited to: fetching and reading official documentation; reading the source code, either on github or locally inside `node_modules`; searching the web for information; running local tests and commands that are non-destructive and do not modify data or the database; adding temporary logging and debugging statements to the codebase.

Always read and understand relevant files before proposing edits. Do not speculate about code you have not inspected. If the user references a specific file/path, you must open and inspect it before explaining or proposing fixes. Be rigorous and persistent in searching code for key facts. Thoroughly review the style, conventions, and abstractions of the codebase before implementing new features or abstractions.

## Type Checking & Linting

Check for type errors regularly during development, not just prior to committing.

Do not suggest that the user runs type checking; run it yourself and act on the results.

In addition to type checking and linting, prior to committing, re-read this document to ensure all instructions are followed and to refresh your memory of the project's guidelines and conventions.

## Version Control & Git

Make smart use of git during development to review changes and understand the history of the codebase.

Never directly make changes to either `dev` or `main` branches without explicit permission.

When handling merges or rebases that involve conflicts, resolve the conflicts but do not finalize the merge commit or rebase; report the resolutions and strategy so the user can complete the finalization.

While resolving merge or rebase conflicts, avoid introducing functional changes; keep merges mechanically faithful so it's clear what came from the merge, and defer any improvements to a separate follow-up.

Never push new branches or new commits to the remote repository unless explicitly instructed to do so by the user.

## Code Style & Conventions

When naming variables, functions, components, etc., favor readability and clarity over brevity or cleverness.

Add comments only when necessary to explain complex code or logic, don't add comments which simply state what the code is doing.

Do not create variables that simply track the exact value of another variable; use the original variable directly instead.

When adding or updating imports for a file, ensure they're sorted in alphabetical order within the following categories: React, environment/runtime, external libraries, internal libraries (monorepo packages), aliased project imports, relative imports, and local imports.

When importing types, add the `type` keyword to the import statement even if it's not required by linting rules.

## TypeScript

Type safety is absolutely critical in all cases. Any new code that uses `any` as a type without a specific exception from the user will be rejected. Any code which uses `as` for type casting will be rejected. Never use `ts-ignore` comments to bypass type checking or `eslint-disable` comments to bypass linting rules.

When defining component prop types that combine specific props with generic passthrough props (like `ComponentProps<typeof X>` or `RootProps`), place the specific props first in the intersection. This ensures component-specific props appear before generic styled props in IntelliSense autocomplete: `{ specific } & RootProps`, not `RootProps & { specific }`.

## HTML & Accessibility

Across all code, prefer semantic HTML first, then a CSS-only implementation for behavior HTML cannot express, then TypeScript/React for behavior CSS cannot express, and only add or rely on external dependencies when absolutely necessary or when they are already in the project.

When choosing HTML tag names, prefer semantic HTML over non-semantic tags (like `<div>` or `<span>`, which should be avoided unless necessary). Prefer built-in semantic HTML elements over using only ARIA attributes for accessibility. Common semantic elements to consider include: `<article>`, `<aside>`, `<details>`, `<figure>`, `<figcaption>`, `<footer>`, `<header>`, `<main>`, `<nav>`, `<menu>`, `<section>`, `<summary>`, `<time>`, `<ul>`, `<ol>`, `<li>`, `<a>`, `<button>`, `<input>`, `<textarea>`, `<select>`, `<option>`, `<label>`, `<form>`, `<fieldset>`, `<legend>`, `<table>`, `<tr>`, `<td>`, `<th>`, `<caption>`, `<colgroup>`, `<tbody>`, `<thead>`, `<tfoot>`, `<dl>`, `<dt>`, `<dd>`, `<h1>`, `<h2>`, `<h3>`, `<h4>`, `<h5>`, `<h6>`, `<p>`, `<blockquote>`, `<code>`, `<pre>`, `<hr>`, `<img>`, `<video>`, `<audio>`.

Prefer screen reader-only text content with proper semantic organization over aria attributes.

## CSS

When writing CSS, use flexbox and grid for layout that reflects the natural flow of the content. Prefer gap properties for spacing between elements, and padding on container elements. Avoid margin unless there's a specific reason to use it, as it makes components less composable/portable.

When writing CSS always use logical properties `block`/`inline`, `start`/`end` instead of `left`, `right`, `top`, and `bottom`.

When writing transforms, use `translate`, `rotate`, `scale`, and other transform sub-properties directly rather than putting them all in a `transform` property.

If using a color that is not a direct token value or CSS custom property, use the `oklch` color space or define it as a hex value, not rgb.

I may refer to CSS custom properties as "tokens", and may call them CSS variables. These are typically interchangeable.

## React

We use React 19, which automatically forwards refs. Do not use `forwardRef` – it is not needed and should not be used.

Avoid `useEffect`. You probably don't need it. Before writing code that uses `useEffect`, always use a web request to read the following article: https://react.dev/learn/you-might-not-need-an-effect

React inline styles may use `as React.CSSProperties` when unavoidable (e.g., view-transition names or CSS custom properties), but this should be rare and inline styles should only very rarely be preferred over classnames. Avoid casting in all other cases.

## Debugging

When debugging complex issues that span multiple components:

1. Add comprehensive logging at key lifecycle points (mounting, state changes, focus events)
2. Use emojis or prefixes to make log categories visually scannable (e.g., `[ComponentName] 🚀 action`, `[ComponentName] 📍 checkpoint`)
3. Log compact string representations rather than full objects for easier copy-pasting: `console.log(\`active=${tag} focused=${bool}\`)`not`console.log({ active, focused })`
4. Include both "before" and "after" snapshots for state changes
5. Remove debug logging after the issue is resolved

When encountering unexpected behavior in third-party libraries or framework-generated code, read the actual source code (including generated files like styled-system, build output, etc.) rather than relying on documentation alone.

## Library Rules

- When importing Lucide icons, always use the `Icon` suffix (e.g., `ArrowRightIcon`, not `ArrowRight`).
