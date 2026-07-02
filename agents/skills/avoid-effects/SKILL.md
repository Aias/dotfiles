---
name: avoid-effects
description: >
  Use when adding or reviewing `useEffect`—unnecessary effects, effect vs event handler, deriving state in
  effects, reset state on prop change, fetch in effect, effect chains, race conditions, or "do I need an
  effect". Triggers on React data-flow and synchronization questions alongside `/react-best-practices`.
  Summary here; full official walkthrough in references/react-dev-full-article.md (react.dev "You Might Not Need an Effect").
global_category: React
---

# Avoid Effects

Effects are for **synchronizing with an external system** (non-React UI, network, browser APIs, subscriptions). If nothing outside React is involved—only props, state, and rendering—you usually **should not** use `useEffect`. Removing unnecessary Effects simplifies code, cuts extra renders, and avoids bugs. Canonical narrative: [react.dev/learn/you-might-not-need-an-effect](https://react.dev/learn/you-might-not-need-an-effect).

For bundle, RSC, memo, and waterfall rules, use `/react-best-practices`. **Read this skill or the full article before adding `useEffect`.**

<!-- @> Effects only for external sync; derive in render; events for interactions; useSyncExternalStore for stores; fetch Effects need stale cleanup -->
## Code smells (often wrong)

| Smell                                                               | Why it’s suspicious                                                        |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| Effect copies props or state into other state for display           | Redundant state; derive during render                                      |
| Effect “reacts” to deps to compute filtered/sorted/merged view data | Belongs in render; use `useMemo` only if profiling shows cost              |
| Effect performs work because user clicked/typed/submitted           | Causation is the **event**; use the event handler (or a function it calls) |
| Several Effects that only `setState` to trigger each other          | Render cascade; compute in render or batch updates in the handler          |
| Effect resets form when `userId` / `savedContact` changes           | Prefer `key={id}` on inner subtree to reset state                          |
| Effect adjusts selection when `items` array identity changes        | Prefer derived selection (e.g. selected id → find item) or keyed reset     |
| Effect calls parent `setState` / `onFetched` to pass data up        | Data should flow down; lift data source to parent                          |
| Effect wraps subscribe + `setState` for browser/store API           | Prefer `useSyncExternalStore` — the test: the value can change without a React event firing (another tab, timer, matchMedia) |
| Effect sends mutation only after user action but deps are “wrong”   | POST/PUT belongs in the handler that knows **why** it ran                  |
| `useEffect(..., [])` for “run once per app” without remount safety  | Strict Mode runs twice in dev; use module scope / root patterns from docs  |

## When an Effect is appropriate vs not

| Situation                                  | Appropriate?                    | Do instead (typical)                                                                                                    |
| ------------------------------------------ | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Value can be computed from props + state   | No                              | Variable in render; [avoid redundant state](https://react.dev/learn/choosing-the-state-structure#avoid-redundant-state) |
| Expensive pure calculation                 | Rarely as Effect                | `useMemo` if measured; [React Compiler](https://react.dev/learn/react-compiler) may memoize                             |
| User clicked / submitted                   | No                              | Event handler                                                                                                           |
| Reset whole subtree when id changes        | No                              | `key={id}` on child                                                                                                     |
| Notify parent on every internal toggle     | No                              | Call parent from same event as `setState`, or controlled props                                                          |
| Child fetched data only for parent         | No                              | Parent fetches, passes props down                                                                                       |
| Subscribe to `online` / external store     | Yes (or `useSyncExternalStore`) | Built-in hook preferred over manual Effect                                                                              |
| Keep jQuery widget in sync with React      | Yes                             | Effect + cleanup                                                                                                        |
| Search results track `query` while visible | Yes, with cleanup               | Framework fetch (SWR/RSC) first; a raw Effect fetch ships races unless cleanup ignores stale responses                  |
| Mount-only analytics                       | Yes, with dev caveats           | See [synchronizing with effects](https://react.dev/learn/synchronizing-with-effects)                                    |

## Decision shortcut

Ask: **Did this run because the user did something specific, or because the component was shown / should stay aligned with an external system?**

- **Specific interaction** → event handler (possibly shared helper).
- **Shown / stay aligned with outside world** → Effect (with cleanup if async or subscribe).

## Full article (offline)

Progressive disclosure: examples, Sandpack, challenges, and edge cases live in [references/react-dev-full-article.md](references/react-dev-full-article.md) (snapshot from [react.dev source](https://github.com/reactjs/react.dev/blob/main/src/content/learn/you-might-not-need-an-effect.md)).
