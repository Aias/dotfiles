---
name: react-best-practices
description: React and Next.js performance optimization and patterns. Use when writing, reviewing, or refactoring React/Next.js code. Triggers on .jsx/.tsx files, React hooks, component patterns, data fetching, bundle optimization, or performance improvements.
global_category: React
---

<!-- @> v19+: no forwardRef. No useEffect for transforms/events/state — calculate in render/handlers -->
<!-- @> Read you-might-not-need-an-effect.md before adding Effects. rAF > setTimeout. Iterate to repeat -->
# React Best Practices

Performance optimization guide for React and Next.js applications. 57 rules across 8 categories, prioritized by impact. Originally adopted from [Vercel Engineering](https://github.com/vercel/next.js) (MIT).

Core rules are compiled into GLOBAL.md. This skill contains additional detail.

## When to Apply

Reference these guidelines when:
- Writing new React components or Next.js pages
- Implementing data fetching (client or server-side)
- Reviewing code for performance issues
- Refactoring existing React/Next.js code
- Optimizing bundle size or load times

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Eliminating Waterfalls | CRITICAL | `async-` |
| 2 | Bundle Size Optimization | CRITICAL | `bundle-` |
| 3 | Server-Side Performance | HIGH | `server-` |
| 4 | Client-Side Data Fetching | MEDIUM-HIGH | `client-` |
| 5 | Re-render Optimization | MEDIUM | `rerender-` |
| 6 | Rendering Performance | MEDIUM | `rendering-` |
| 7 | JavaScript Performance | LOW-MEDIUM | `js-` |
| 8 | Advanced Patterns | LOW | `advanced-` |

## Quick Reference

### 1. Eliminating Waterfalls (CRITICAL)

- [`async-defer-await`](references/async-defer-await.md) — Move await into branches where actually used
- [`async-parallel`](references/async-parallel.md) — Use Promise.all() for independent operations
- [`async-dependencies`](references/async-dependencies.md) — Use better-all for partial dependencies
- [`async-api-routes`](references/async-api-routes.md) — Start promises early, await late in API routes
- [`async-suspense-boundaries`](references/async-suspense-boundaries.md) — Use Suspense to stream content

### 2. Bundle Size Optimization (CRITICAL)

- [`bundle-barrel-imports`](references/bundle-barrel-imports.md) — Import directly, avoid barrel files
- [`bundle-dynamic-imports`](references/bundle-dynamic-imports.md) — Use next/dynamic for heavy components
- [`bundle-defer-third-party`](references/bundle-defer-third-party.md) — Load analytics/logging after hydration
- [`bundle-conditional`](references/bundle-conditional.md) — Load modules only when feature is activated
- [`bundle-preload`](references/bundle-preload.md) — Preload on hover/focus for perceived speed

### 3. Server-Side Performance (HIGH)

- [`server-auth-actions`](references/server-auth-actions.md) — Authenticate server actions like API routes
- [`server-cache-react`](references/server-cache-react.md) — Use React.cache() for per-request deduplication
- [`server-cache-lru`](references/server-cache-lru.md) — Use LRU cache for cross-request caching
- [`server-dedup-props`](references/server-dedup-props.md) — Avoid duplicate serialization in RSC props
- [`server-serialization`](references/server-serialization.md) — Minimize data passed to client components
- [`server-parallel-fetching`](references/server-parallel-fetching.md) — Restructure components to parallelize fetches
- [`server-after-nonblocking`](references/server-after-nonblocking.md) — Use after() for non-blocking operations

### 4. Client-Side Data Fetching (MEDIUM-HIGH)

- [`client-swr-dedup`](references/client-swr-dedup.md) — Use SWR for automatic request deduplication
- [`client-event-listeners`](references/client-event-listeners.md) — Deduplicate global event listeners
- [`client-passive-event-listeners`](references/client-passive-event-listeners.md) — Use passive listeners for scroll
- [`client-localstorage-schema`](references/client-localstorage-schema.md) — Version and minimize localStorage data

### 5. Re-render Optimization (MEDIUM)

- [`rerender-defer-reads`](references/rerender-defer-reads.md) — Don't subscribe to state only used in callbacks
- [`rerender-memo`](references/rerender-memo.md) — Extract expensive work into memoized components
- [`rerender-memo-with-default-value`](references/rerender-memo-with-default-value.md) — Hoist default non-primitive props
- [`rerender-dependencies`](references/rerender-dependencies.md) — Use primitive dependencies in effects
- [`rerender-derived-state`](references/rerender-derived-state.md) — Subscribe to derived booleans, not raw values
- [`rerender-derived-state-no-effect`](references/rerender-derived-state-no-effect.md) — Derive state during render, not effects
- [`rerender-functional-setstate`](references/rerender-functional-setstate.md) — Use functional setState for stable callbacks
- [`rerender-lazy-state-init`](references/rerender-lazy-state-init.md) — Pass function to useState for expensive values
- [`rerender-simple-expression-in-memo`](references/rerender-simple-expression-in-memo.md) — Avoid memo for simple primitives
- [`rerender-move-effect-to-event`](references/rerender-move-effect-to-event.md) — Put interaction logic in event handlers
- [`rerender-transitions`](references/rerender-transitions.md) — Use startTransition for non-urgent updates
- [`rerender-use-ref-transient-values`](references/rerender-use-ref-transient-values.md) — Use refs for transient frequent values

### 6. Rendering Performance (MEDIUM)

- [`rendering-animate-svg-wrapper`](references/rendering-animate-svg-wrapper.md) — Animate div wrapper, not SVG element
- [`rendering-content-visibility`](references/rendering-content-visibility.md) — Use content-visibility for long lists
- [`rendering-hoist-jsx`](references/rendering-hoist-jsx.md) — Extract static JSX outside components
- [`rendering-svg-precision`](references/rendering-svg-precision.md) — Reduce SVG coordinate precision
- [`rendering-hydration-no-flicker`](references/rendering-hydration-no-flicker.md) — Use inline script for client-only data
- [`rendering-hydration-suppress-warning`](references/rendering-hydration-suppress-warning.md) — Suppress expected mismatches
- [`rendering-activity`](references/rendering-activity.md) — Use Activity component for show/hide
- [`rendering-conditional-render`](references/rendering-conditional-render.md) — Use ternary, not && for conditionals
- [`rendering-usetransition-loading`](references/rendering-usetransition-loading.md) — Prefer useTransition for loading state

### 7. JavaScript Performance (LOW-MEDIUM)

- [`js-batch-dom-css`](references/js-batch-dom-css.md) — Group CSS changes via classes or cssText
- [`js-index-maps`](references/js-index-maps.md) — Build Map for repeated lookups
- [`js-cache-property-access`](references/js-cache-property-access.md) — Cache object properties in loops
- [`js-cache-function-results`](references/js-cache-function-results.md) — Cache function results in module-level Map
- [`js-cache-storage`](references/js-cache-storage.md) — Cache localStorage/sessionStorage reads
- [`js-combine-iterations`](references/js-combine-iterations.md) — Combine multiple filter/map into one loop
- [`js-length-check-first`](references/js-length-check-first.md) — Check array length before expensive comparison
- [`js-early-exit`](references/js-early-exit.md) — Return early from functions
- [`js-hoist-regexp`](references/js-hoist-regexp.md) — Hoist RegExp creation outside loops
- [`js-min-max-loop`](references/js-min-max-loop.md) — Use loop for min/max instead of sort
- [`js-set-map-lookups`](references/js-set-map-lookups.md) — Use Set/Map for O(1) lookups
- [`js-tosorted-immutable`](references/js-tosorted-immutable.md) — Use toSorted() for immutability

### 8. Advanced Patterns (LOW)

- [`advanced-event-handler-refs`](references/advanced-event-handler-refs.md) — Store event handlers in refs
- [`advanced-init-once`](references/advanced-init-once.md) — Initialize app once per app load
- [`advanced-use-latest`](references/advanced-use-latest.md) — useLatest for stable callback refs

## Additional References

- [`you-might-not-need-an-effect`](references/you-might-not-need-an-effect.md) — Comprehensive guide to when Effects are and aren't appropriate. **Read before adding any `useEffect`.**
