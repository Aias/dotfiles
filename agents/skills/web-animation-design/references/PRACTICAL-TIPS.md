# Practical Animation Tips

Detailed reference guide for common animation scenarios. Use this as a checklist when implementing animations.

## Recording & Debugging

### Record Your Animations

When something feels off but you can't identify why, record the animation and play it back frame by frame (or slow it 2–5× with the DevTools animation inspector). This reveals details invisible at normal speed: colors that don't crossfade cleanly, easing that stops abruptly, a wrong `transform-origin`, coordinated properties drifting out of sync.

### Fix Shaky Animations

Elements may shift by 1px at the start/end of CSS transform animations due to GPU/CPU rendering handoff.

**Fix:**

```css
.element {
  will-change: transform;
}
```

This tells the browser to keep the element on the GPU throughout the animation. Add it only once you actually see the shift or dropped frames—browsers already promote `transform`/`opacity` animations automatically, and every extra layer costs GPU memory. Never sprinkle it preemptively.

### Take Breaks

Don't code and ship animations in one sitting. Step away, return with fresh eyes. The best animations are reviewed and refined over days, not hours.

## Button & Click Feedback

### Scale Buttons on Press

Make interfaces feel responsive by adding subtle scale feedback:

```css
button:active {
  transform: scale(0.97);
}
```

Press feedback is felt, not seen—`scale(0.9)` visibly collapses. Pair with a hover state; hover with nothing on click feels dead.

### Don't Animate from scale(0)

Starting from `scale(0)` makes elements appear from nowhere—it feels unnatural.

**Bad:**

```css
.element {
  transform: scale(0);
}
.element.visible {
  transform: scale(1);
}
```

**Good:**

```css
.element {
  transform: scale(0.95);
  opacity: 0;
}
.element.visible {
  transform: scale(1);
  opacity: 1;
}
```

Elements should always have some visible shape, like a deflated balloon. The bigger the floating element, the closer its initial scale sits to 1 (a wide nav menu enters from `scale(0.98)`).

## Enter & Exit Without JS

### Enter with @starting-style

The modern way to animate an element in on first render, fully interruptible:

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

Legacy fallback: mount with an initial state, flip a `data-mounted` attribute in an effect, and transition to the target.

### Exit with [data-state]

Radix and Base UI suspend unmount so a closing animation can play, driven by `[data-state]`:

```css
@keyframes scaleIn  { from { opacity: 0; scale: 0.98; } to { opacity: 1; scale: 1; } }
@keyframes scaleOut { to { opacity: 0; scale: 0.98; } } /* omit `from` — inherits current values */
.content[data-state="open"]   { animation: scaleIn 200ms ease; }
.content[data-state="closed"] { animation: scaleOut 200ms ease; }
```

### Transitions Beat Keyframes for Dynamic UI

Transitions interpolate from the *current* value, so they stay smooth when interrupted or reversed. `@keyframes` restart from zero—new toasts jump, rapidly-toggled drawers stutter. Reserve keyframes for autonomous motion: page-load intros, infinite loops (marquee, spinner), multi-step effects (pulse, shake).

Other transition rules:

- Put the transition on the base state, not only `:hover`—otherwise the return to default is instant.
- Avoid `transition: all`—be explicit so you never animate an unintended property.
- Re-trigger a keyframe animation in React by changing the element's `key`.

## Toasts & Stacked Cards

Stack with `translateY` + `scale` driven by an inverted `--index`, so adding cards never touches the CSS:

```css
.card {
  --scale-increment: 0.05;
  --translate-increment: -13%;
  transform:
    scale(calc(1 - var(--index) * var(--scale-increment)))
    translateY(calc(var(--index) * var(--translate-increment)));
}
```

Pass `style={{ "--index": LENGTH - 1 - i }}` so the front card is index 0. `translate` percentages are relative to the element's own size—`translateY(100%)` moves an element by its own height regardless of dimensions, which is how toasts and drawers position themselves robustly.

## Tooltips & Popovers

### Skip Animation on Subsequent Tooltips

First tooltip: delay + animation. Subsequent tooltips (while one is open): instant, no delay.

```css
.tooltip {
  transition:
    transform 125ms ease-out,
    opacity 125ms ease-out;
  transform-origin: var(--transform-origin);
}

.tooltip[data-starting-style],
.tooltip[data-ending-style] {
  opacity: 0;
  transform: scale(0.97);
}

/* Skip animation for subsequent tooltips */
.tooltip[data-instant] {
  transition-duration: 0ms;
}
```

Radix UI and Base UI support this pattern with `data-instant` attribute.

### Make Animations Origin-Aware

Popovers should scale from their trigger, not from center.

```css
/* Default (wrong for most cases) */
.popover {
  transform-origin: center;
}

/* Correct - scale from trigger */
.popover {
  transform-origin: var(--transform-origin);
}
```

**Radix UI:**

```css
.popover {
  transform-origin: var(--radix-dropdown-menu-content-transform-origin);
}
```

**Base UI:**

```css
.popover {
  transform-origin: var(--transform-origin);
}
```

**Modals are exempt**—they appear centered, so `transform-origin: center` is correct for them.

## Speed & Timing

### Keep Animations Fast

A faster-spinning spinner makes apps feel faster even with identical load times. A 180ms select animation feels more responsive than 400ms.

**Rule:** UI animations should stay under 300ms unless justified by element size, travel distance, or a very steep curve.

### Choose Easing First, Then Duration

Duration and easing are one decision, not two. A steep curve front-loads the movement, so it can afford a longer duration; a weak curve must be shorter. When an animation feels flat or slow, reach for a stronger curve before a shorter duration.

### Asymmetric Timing

Slow where the user is deciding, fast where the system responds. Declare different transitions on the base vs active state—a hold-to-delete overlay reveals slowly and evenly while held, and snaps back fast on release:

```css
.hold-overlay { transition: clip-path 0.2s ease-out; }              /* release: fast snap-back */
.button:active .hold-overlay { transition: clip-path 1.5s linear; } /* hold: slow, even reveal */
.button:active { transform: scale(0.97); }
```

### Don't Animate Keyboard Interactions

Arrow key navigation, keyboard shortcuts—these are repeated hundreds of times daily. Animation makes them feel slow and disconnected.

**Never animate:**

- List navigation with arrow keys
- Keyboard shortcut responses
- Tab/focus movements

### Be Careful with Frequently-Used Elements

A hover effect is nice, but if triggered multiple times a day, it may benefit from no animation at all.

**Guideline:** Use your own product daily. You'll discover which animations become annoying through repeated use.

## Hover States

### Fix Hover Flicker

When hover animation changes element position, the cursor may leave the element, causing flicker.

**Problem:**

```css
.box:hover {
  transform: translateY(-20%);
}
```

**Solution:** Animate a child element instead:

```html
<div class="box">
  <div class="box-inner"></div>
</div>
```

```css
.box:hover .box-inner {
  transform: translateY(-20%);
}

.box-inner {
  transition: transform 200ms ease;
}
```

The parent's hover area stays stable while the child moves.

### Keyboard and Touch Parity

Hover-revealed info must also be reachable by keyboard—pair `:hover` with `:focus-visible` (not `:focus`, which also fires on click):

```css
.card:hover .desc,
.card:focus-visible .desc {
  transform: translateY(0);
}
```

### Disable Hover on Touch Devices

Touch devices don't have true hover. Accidental finger movement triggers unwanted hover states.

```css
@media (hover: hover) and (pointer: fine) {
  .card:hover {
    transform: scale(1.05);
  }
}
```

**Note:** Tailwind v4's `hover:` class automatically applies only when the device supports hover.

## clip-path Patterns

`clip-path` clips an element to a shape with no layout effect and is hardware-accelerated—often better than animating `width`/`height`. `inset(top right bottom left)` eats in from each side.

- **Image reveal on scroll**—animate `inset(100%)` → `inset(0)`; more performant than height and avoids layout shift. Trigger with Intersection Observer so the user actually sees it.
- **Comparison slider**—overlay two images; the top one gets `clip-path: inset(0 50% 0 0)`, adjusted by drag.
- **Seamless tab highlight**—duplicate the tab list styled active, clip it to the active tab, animate the clip on click.
- **Hold-to-delete**—a red `position: absolute; inset: 0` overlay hidden from the right (`inset(0 100% 0 0)`), revealed left→right while held (see Asymmetric Timing above).
- **Animated corner radius**—`clip-path: inset(0 round 12px)` composites; animating `border-radius` repaints every frame.

## Framer Motion Gotchas

- **`AnimatePresence` requires a `key`** on the animating child or the exit animation never fires. If an exit isn't playing, check the key first.
- **Pass `custom` to both** `AnimatePresence` and the `motion` element—an exiting element's props are otherwise stale, which breaks direction-aware slides.
- **Layout animations distort `border-radius`** (they use `transform`); the radius is corrected only when it's in pixels. Use inline `style={{ borderRadius: 12 }}`, never a `rem`/className radius, when animating layout.
- **Animating height:** measure the content (`ResizeObserver`/`useMeasure`) and animate to the number—`auto` → `auto` can't animate. Put the `ref` on an *inner* element that carries the padding, not the element with `animate={{ height }}`.
- **Text swaps:** keyed `motion.span` in `AnimatePresence mode="popLayout" initial={false}`, entering from one side and exiting to the other with `{ type: "spring", duration: 0.3, bounce: 0 }`. Use `tabular-nums` for changing digits so widths stay fixed.

## Touch & Accessibility

### Ensure Appropriate Target Areas

Small buttons are hard to tap. Use a pseudo-element to create larger hit areas without changing layout.

**Minimum target:** 44px (Apple and WCAG recommendation)

```css
@utility touch-hitbox {
  position: relative;
}

@utility touch-hitbox::before {
  content: '';
  position: absolute;
  display: block;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 100%;
  height: 100%;
  min-height: 44px;
  min-width: 44px;
  z-index: 9999;
}
```

Usage:

```jsx
<button className="touch-hitbox">
  <BellIcon />
</button>
```

### Pause Loops on a Hero Frame

Under `prefers-reduced-motion: reduce`, pause looping animations on a representative frame rather than frame 0:

```css
@media (prefers-reduced-motion: reduce) {
  .loop {
    animation-play-state: paused;
    animation-delay: -0.4s; /* jump to the frame worth showing */
  }
}
```

For essential visual sequences (a metaphor the motion itself explains), jump between frames instead of tweening—the user still gets every state; nothing slides.

## Easing Selection

### Use ease-out for Enter/Exit

Elements entering or exiting should use `ease-out`. The fast start creates responsiveness.

```css
.dropdown {
  transition:
    transform 200ms ease-out,
    opacity 200ms ease-out;
}
```

`ease-in` starts slow—wrong for UI. Same duration feels slower because the movement is back-loaded.

### Use ease-in-out for On-Screen Movement

Elements already visible that need to move should use `ease-in-out`. Mimics natural acceleration/deceleration like a car.

```css
.slider-handle {
  transition: transform 250ms ease-in-out;
}
```

### Use Custom Easing Curves

Built-in CSS curves are usually too weak—their acceleration is flat, so animations feel lifeless. Custom asymmetric curves (steep start, slow settle) mimic a spring without one.

**Resources:**

- Course reference: `/learn/easing-curves`
- External: [easings.co](https://easings.co/)

## Visual Tricks

### Use Blur as a Fallback

When easing and timing adjustments don't solve the problem, add subtle blur to mask imperfections.

```css
.button-transition {
  transition:
    transform 150ms ease-out,
    filter 150ms ease-out;
}

.button-transition:active {
  transform: scale(0.97);
  filter: blur(2px);
}
```

Blur bridges visual gaps between states, tricking the eye into seeing smoother transitions. The two states blend instead of appearing as distinct objects. The same trick rescues a crossfade that shows both states overlapping.

**Performance note:** Keep animated blur small (2–5px is plenty; never above ~20px, especially on Safari).

## Why Details Matter

> "All those unseen details combine to produce something that's just stunning, like a thousand barely audible voices all singing in tune."
> — Paul Graham, Hackers and Painters

Details that go unnoticed are good—users complete tasks without friction. Great interfaces enable users to achieve goals with ease, not to admire animations.
