---
name: web-animation-design
description: >
  Use whenever motion questions arise—easing, duration, springs, entrance/exit, hover, stagger,
  scroll-linked animation, interruptibility, reduced motion, or "janky"/"make it smooth". Triggers on
  Framer Motion (motion/react), GSAP, CSS keyframes/transitions, cubic-bezier, @starting-style,
  clip-path, transform-origin, modal/drawer/tooltip/toast motion, drag/gesture feel, GPU-safe
  properties. Design and implement purposeful web animation.
---

# Web Animation Design

A comprehensive guide for creating animations that feel right, based on Emil Kowalski's "Animations on the Web" course.

## Review Format

When reviewing animations, present findings as a single markdown table, one row per issue:

| Before                            | After                                            | Why                                          |
| --------------------------------- | ------------------------------------------------ | -------------------------------------------- |
| `transform: scale(0)`             | `transform: scale(0.95); opacity: 0`             | Nothing appears from nothing                 |
| `animation: fadeIn 400ms ease-in` | `animation: fadeIn 200ms ease-out`               | `ease-in` delays the moment the user watches |
| No reduced motion support         | `@media (prefers-reduced-motion: reduce) {...}`  | Movement removed, meaning kept               |

## Decision Framework

Answer these in order, before writing animation code.


### 1. Should this animate at all?

Match motion to how often the user sees it:

| Frequency                                                    | Decision                       |
| ------------------------------------------------------------ | ------------------------------ |
| 100+/day (keyboard shortcuts, command palette, arrow-key nav) | No animation. Ever.            |
| Tens/day (hover effects, list navigation)                     | Remove or drastically reduce   |
| Occasional (modals, drawers, toasts)                          | Standard animation             |
| Rare / first-time (onboarding, celebrations)                  | Can add delight                |

Never animate keyboard-initiated actions—they repeat hundreds of times daily; animation makes them feel slow and disconnected. High-frequency selection highlights must be **instant** (track the cursor exactly), not a smooth fade that trails one step behind.

### 2. What's the purpose?

Every animation needs one: feedback/responsiveness, spatial consistency, state indication, explanation, preventing a jarring change, or—rarely, for seldom-seen interactions—delight. "It looks cool" on a frequently-seen element is not a purpose. If everything animates, nothing stands out.

**Marketing vs. product:** marketing pages (landing pages, one-shot hero moments) can run longer and more elaborate; product must feel fast—the frequency table decides borderline cases.

### 3. Then pick the ingredients

Easing → duration → physicality → (spring?) → interruptibility → performance → accessibility. The rest of this skill is those ingredients.

## The Easing Blueprint

Easing is the single most important part of an animation—it can make a bad animation look great or a great one feel wrong.

| Situation                                            | Curve                                       |
| ---------------------------------------------------- | ------------------------------------------- |
| Entering or exiting the screen                       | `ease-out` (fast start feels responsive)    |
| Moving/morphing while already on screen              | `ease-in-out` (car accelerating then braking) |
| Hover / color / background / opacity                 | `ease` (asymmetric, elegant for small changes) |
| Constant motion (marquee, spinner, hold-to-delete)   | `linear`                                    |
| Default                                              | `ease-out`                                  |

**Never use `ease-in` on UI.** It starts slow—delaying the exact moment the user is watching—then accelerates into the stop, the opposite of how things settle.


### Use custom curves

Built-in named curves are almost never strong enough—their acceleration is too weak, so animations feel flat. Treat `ease-out`/`ease-in-out` as *categories*, then pick a real cubic-bezier. Prefer asymmetric curves (steep start, slow settle)—they feel alive and mimic a spring without one. **When an animation feels flat, the curve is probably too weak, not the duration.**

```css
/* ease-out, sorted weak to strong */
--ease-out-quad: cubic-bezier(0.25, 0.46, 0.45, 0.94);   /* button press */
--ease-out-cubic: cubic-bezier(0.215, 0.61, 0.355, 1);
--ease-out-quart: cubic-bezier(0.165, 0.84, 0.44, 1);
--ease-out-quint: cubic-bezier(0.23, 1, 0.32, 1);
--ease-out-expo: cubic-bezier(0.19, 1, 0.22, 1);         /* strong: hovers, reveals */
--ease-out-circ: cubic-bezier(0.075, 0.82, 0.165, 1);

/* ease-in-out, sorted weak to strong */
--ease-in-out-quad: cubic-bezier(0.455, 0.03, 0.515, 0.955);
--ease-in-out-cubic: cubic-bezier(0.645, 0.045, 0.355, 1); /* on-screen back-and-forth */
--ease-in-out-quart: cubic-bezier(0.77, 0, 0.175, 1);
--ease-in-out-quint: cubic-bezier(0.86, 0, 0.07, 1);
--ease-in-out-expo: cubic-bezier(1, 0, 0, 1);
--ease-in-out-circ: cubic-bezier(0.785, 0.135, 0.15, 0.86);

/* proven in production */
--ease-sheet: cubic-bezier(0.32, 0.72, 0, 1);   /* iOS-style sheet — extremely steep start */
--ease-height: cubic-bezier(0.25, 1, 0.5, 1);   /* snappy drawer height change */
```


### Paired Elements Rule

Elements that animate together must use the same easing and duration. Modal + overlay, tooltip + arrow, drawer + backdrop—if they move as a unit, they should feel like a unit.

```css
/* Both use the same timing */
.modal {
  transition: transform 200ms ease-out;
}
.overlay {
  transition: opacity 200ms ease-out;
}
```

## Timing and Duration


**Duration and easing are inseparable.** A steep curve can afford a longer duration (a 500ms iOS sheet doesn't feel slow because the curve front-loads the movement); a weak curve must be shorter. Choose the easing first, then tune duration to it.

| Element Type                      | Duration   |
| --------------------------------- | ---------- |
| Button press feedback             | ~150ms     |
| Tooltips, small popovers          | 125–200ms  |
| Dropdowns, selects                | 150–250ms  |
| Modals, drawers                   | 200–300ms (up to ~500ms with a very steep curve) |
| Page transitions                  | 300–400ms  |

**Rules:**

- UI animations stay under ~300ms unless justified by element size, travel distance, or a very steep curve. A 180ms dropdown feels more responsive than a 400ms one; a faster spinner makes loads *feel* faster.
- Duration scales with element size and travel distance—a bigger element is heavier (tooltip ~120ms, full-screen drawer ~280ms).
- **Exits are shorter and simpler than entries**—the user already decided; get out of the way.
- Too fast is as bad as too slow.
- For transitions whose size varies (an auto-height drawer), make duration proportional to how much changed so small changes don't over-animate.

## Physicality


- **Never animate from `scale(0)`.** Start entrances from `scale(0.9–0.95)` + `opacity: 0`—nothing appears from nothing; a near-full start reads as "it was always almost there." Bigger floating elements start closer to 1 (a nav menu uses `scale(0.98)`).
- **Button press:** `transform: scale(0.97)` on `:active`. Press feedback is *felt, not seen*—`scale(0.9)` visibly collapses. Buttons feel best with both hover and press feedback; hover with nothing on click feels dead.
- **Hover scale:** 1–2% is plenty (`scale(1.02)`). `hover:scale-105` inflates like a balloon. Hover duration 100–150ms.
- **Origin-aware popovers:** scale from the trigger, not the center—the CSS default `transform-origin: center` is wrong for almost every triggered element. **Modals are exempt**: they appear centered, keep `transform-origin: center`.

  ```css
  .popover { transform-origin: var(--radix-popover-content-transform-origin); } /* Radix */
  .popover { transform-origin: var(--transform-origin); }                       /* Base UI */
  ```

- **Never put a hover lift on the hover target itself.** Animating `translateY` on the hovered element moves it out from under the cursor → hover ends → it drops → flicker loop. Move the lift to an inner child; the parent stays under the cursor.

## Spring Animations

Springs simulate physics (mass, stiffness, damping) with no fixed duration, so they feel organic. Real springs are impossible in pure CSS (only approximable with `linear()`).

### When to Use Springs

- Drag interactions with momentum
- Gestures that can be interrupted mid-animation (springs retarget smoothly from current velocity; curves jump)
- Cursor-following and "alive" elements

An interaction that is neither a gesture nor interruptible takes the easing curves above by default—"it should feel alive/organic" is a wish, not a trigger. Simple color/opacity changes never need a spring.

### Configuration

```js
// Apple/Motion style (easier to reason about) — great for UI text/state swaps
{ type: "spring", duration: 0.3, bounce: 0 }
{ type: "spring", duration: 0.5, bounce: 0.2 }
// Physics form (more control)
{ type: "spring", stiffness: 100, damping: 10, mass: 0.75 }
```

### Bounce Guidelines

- **Default bounce to 0.** No overshoot keeps UI natural and elegant. Add bounce only intentionally—a slight bounce at the *end of a drag* (a drag applies force); a press-to-close gets none. Bounce is personality: more = playful, zero = serious.
- **Bounce scales inversely with element size**—smaller elements need *more* bounce to read the same amount.
- "Weird" spring motion is usually fixed by increasing `damping`.
- In Motion, `useSpring` for most interactions (a raw `useMotionValue` feels lifeless); `useMotionValue` when the value must track a gesture 1:1 (drag-to-dismiss).

## Interruptibility


Anything triggered rapidly (toasts, toggles, drawers, accordions, drags) must animate **from its current state**, not restart. CSS transitions and springs are interruptible; `@keyframes` restart from zero and make new items jump. Reserve `@keyframes` for autonomous, looping, or one-shot motion that never needs interruption.

Enter without JS via `@starting-style`:

```css
.toast {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 400ms ease, transform 400ms ease;
  @starting-style {
    opacity: 0;
    transform: translateY(100%);
  }
}
```

Radix/Base UI animate exit via `[data-state]` (they suspend unmount so the closing animation plays):

```css
@keyframes scaleIn  { from { opacity: 0; scale: 0.98; } to { opacity: 1; scale: 1; } }
@keyframes scaleOut { to { opacity: 0; scale: 0.98; } } /* omit `from` — inherits current */
.content[data-state="open"]   { animation: scaleIn 200ms ease; }
.content[data-state="closed"] { animation: scaleOut 200ms ease; }
```

**Asymmetric timing:** slow where the user is deciding, fast where the system responds—declare different transitions on the base vs `:active` state (a hold-to-delete reveals over 1.5s `linear` while held, snaps back in 0.2s on release).

## Performance

### The Golden Rule


Only animate `transform` and `opacity`. These touch just the Composite step and run on the GPU. Everything else costs more:

| Tier                       | Properties                                              | Cost                          |
| -------------------------- | ------------------------------------------------------- | ----------------------------- |
| Composite only             | `transform`, `opacity`                                  | Cheapest—animate by default   |
| Paint + Composite          | `box-shadow`, `border-radius`, `color`                  | Expensive redraw every frame  |
| Layout + Paint + Composite | `height`, `width`, `padding`, `margin`, `top`, `left`   | Most expensive—drops frames   |

**Swap down a tier:**

| Instead of                          | Animate                                          |
| ----------------------------------- | ------------------------------------------------ |
| `width`/`height`/`padding` to grow  | `scale()`                                        |
| `margin`/`top`/`left` to move       | `translate()` (percentages—relative to own size) |
| `box-shadow`                        | `filter: drop-shadow(...)`                       |
| `border-radius`                     | `clip-path: inset(0 round 12px)`                 |

### Main-Thread Traps

An animation can be `transform`-only and still jank:

- **Framer Motion `x`/`y`/`scale` shorthands are not hardware-accelerated**—they're CSS variables under the hood, driven by rAF on the main thread. When motion must survive a busy main thread (page transitions, tab switches during navigation), animate the full string: `animate={{ transform: "translateX(100px)" }}`.
- **Don't drive child transforms through a CSS variable on a shared parent**—inherited variables trigger style recalculation for every descendant, every frame. The tell is a `transform` animation that degrades as content grows. Set `transform` directly on the element.
- **Don't animate through React state**—a state update per frame re-renders per frame. Write to a motion value or `ref.current.style` instead.
- **CSS/WAAPI beat JS under load**—they run off the main thread. Use CSS for predetermined motion, JS for dynamic/interruptible motion.
- **Keep animated `blur()` under ~20px** (2–5px is plenty to mask a crossfade)—blur gets laggy fast, especially in Safari.

### will-change

`will-change: transform` fixes the 1px CPU↔GPU handoff shift and promotes expensive filtered/blurred elements to their own layer—but **add it only once you actually see the shift or dropped frames**. Browsers already promote `transform`/`opacity` animations automatically, and every extra layer costs GPU memory. Target the elements that animate, never everything.

Never conclude "it's fine" from your own machine; a mid-range phone is the bar.

## Stagger and Orchestration

Stagger group entrances 30–80ms apart—longer feels slow, and stagger is decorative so it must never block interaction. **Vary the delay and distance by visual importance**: the most important element appears first with the most screen time; the least important can just fade in without sliding. Uniform stagger (identical delay/distance/easing per item) kills hierarchy and feels artificial.

**One entrance per container.** Don't slide a panel in *and* trickle its children in—slide it in with content already there. Sometimes the best animation is no animation.

Ambient "subtle life" (idle floats): use deliberately non-syncing durations (e.g. 3s and 4s) so layers never line up and the motion reads organic, not mechanical.

## Cohesion and Spatial Consistency

- All of a component's sub-animations should share a timing feel so it reads as a single entity—override library defaults when needed so opening and content changes feel unified.
- **Exit direction matches entry direction**; navigation maps forward = left, back = right. A zoomed view expands from its thumbnail (object permanence)—it doesn't fade in from nowhere.
- Match motion to the component's personality—playful can be bouncier; a dashboard stays crisp.
- Prefer a crossfade with a subtle directional hint (8px shift + opacity + light blur) over a heavy full slide for small, structurally-similar content. When a crossfade shows two overlapping states despite tuning, a subtle `filter: blur(2px)` during the transition blends them into one perceived transformation.
- Use `tabular-nums` for changing digits (timers, counters) so widths stay fixed and don't shift.

## Accessibility

Animations can cause motion sickness or distraction for some users—vestibular disorders are real and common. The preference is set at the OS level, so users expect every site to honor it.

### prefers-reduced-motion


**Reduced motion means gentler, not zero.** Deleting all animation makes the interface *harder* to follow. The transformation is: remove the motion, keep the meaning.

| Under `reduce`                                          | Do                                                 |
| ------------------------------------------------------- | -------------------------------------------------- |
| Movement—`transform`, `translate`, `scale`, position    | Remove. Nothing should move.                       |
| Meaning—`opacity`, `color`, `background-color`          | Keep. These carry the state change without motion. |
| Autoplaying and looping animation                       | Disable, or pause on a representative "hero" frame |
| Purely decorative motion (idle float, ambient loop)     | Remove entirely—lingering motion falsely implies interactivity |

A modal that scales in becomes a modal that fades in. A sidebar that slides from `-100%` fades instead. Swap the animation, don't just delete it:

```css
.modal {
  animation: scaleFadeIn 200ms ease-out;
}

@media (prefers-reduced-motion: reduce) {
  .modal {
    animation: fadeIn 200ms ease-out; /* replace movement, don't delete meaning */
  }
}
```

Build the animation first, then adjust for reduced motion as a second pass—and *watch* the reduce variant with DevTools emulation on (Rendering panel). The common failure is a "reduced" variant that still moves because one `transform` was left behind.

### Framer Motion Implementation

```jsx
import { useReducedMotion } from "motion/react";

function Sidebar({ isOpen }) {
  const shouldReduceMotion = useReducedMotion();
  const closedX = shouldReduceMotion ? 0 : "-100%";
  return <motion.div animate={{ opacity: isOpen ? 1 : 0, x: isOpen ? 0 : closedX }} />;
}
```

Also gate what CSS can't reach: skip `animate={{ height }}` and pass `layout={false}` under reduce—layout animations move things by definition. App-wide safety net: `<MotionConfig reducedMotion="user">` animates only opacity/background everywhere below it (the default is `never`, so it does nothing until set).

### Touch Device Considerations

```css
/* Hover belongs to pointers — touch fires false hovers on tap */
@media (hover: hover) and (pointer: fine) {
  .element:hover {
    transform: scale(1.02);
  }
}
```

Make tap targets ≥ 44×44px (enlarge with an invisible `::before` hitbox without changing layout).

## Practical Tips

Quick reference for common scenarios. See [PRACTICAL-TIPS.md](references/PRACTICAL-TIPS.md) for detailed implementations.

| Scenario                        | Solution                                        |
| ------------------------------- | ----------------------------------------------- |
| Make buttons feel responsive    | Add `transform: scale(0.97)` on `:active`       |
| Element appears from nowhere    | Start from `scale(0.95)` + `opacity: 0`         |
| Animation feels flat            | Stronger custom curve, not longer duration      |
| New toasts/items jump on arrival| Use transitions/springs, not `@keyframes`       |
| Enter animation without JS      | `@starting-style`                               |
| Shaky/jittery animations        | `will-change: transform` (only once seen)       |
| Hover causes flicker            | Animate child element, not parent               |
| Popover scales from wrong point | Set `transform-origin` to trigger location      |
| Sequential tooltips feel slow   | Skip delay/animation after first tooltip        |
| Transform jank grows with list  | CSS variable on parent—set transform directly   |
| Small buttons hard to tap       | Use 44px minimum hit area (pseudo-element)      |
| Crossfade shows both states     | Subtle blur (2–5px) during the transition       |
| Hover triggers on mobile        | Use `@media (hover: hover) and (pointer: fine)` |

## Process

Great animations take iteration, not one sitting.

- **Record and scrub** the reference (and your own work) frame by frame—this reveals details invisible at normal speed. Tune magic transform values live in the console.
- **Don't code and ship in one sitting**—review with fresh eyes the next day.
- **Test gestures on real devices**—hit the dev server by IP; profile on a mid-range phone, not a throttled desktop (throttling models a slow CPU, not a weak GPU).
- Steal like an artist: recreate great animations by studying proven products rather than inventing patterns.

## Easing Decision Flowchart

Is the element entering or exiting the viewport?
├── Yes → ease-out
└── No
├── Is it moving/morphing on screen?
│ └── Yes → ease-in-out
└── Is it a hover change?
├── Yes → ease
└── Is it constant motion?
├── Yes → linear
└── Default → ease-out

## Reference Files

- [PRACTICAL-TIPS.md](references/PRACTICAL-TIPS.md) - Detailed implementations for common animation scenarios
