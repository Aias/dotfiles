---
name: remove-effects
description: Identify and remove unnecessary useEffect hooks in React components
---

# Remove Unnecessary Effects

Apply this skill when reviewing or refactoring React components that use `useEffect`. Effects are an escape hatch for synchronizing with external systems—they should NOT be used for data transformation, event handling, or state derivation.

**Reference:** See `reference.md` in this skill directory for the full React documentation.

## When to Apply This Skill

- User asks to review/refactor React code
- You encounter `useEffect` while implementing changes
- User mentions performance issues or "too many re-renders"
- Code has cascading state updates or complex effect chains

## Core Principle

> "Use Effects only for code that should run _because_ the component was displayed to the user."

If code runs in response to a user action, it belongs in an event handler—not an Effect.

---

## Pattern Recognition Guide

### 1. Derived State (REMOVE)

**Symptom:** Effect updates state based on other state/props

```jsx
// 🔴 Bad
const [fullName, setFullName] = useState("");
useEffect(() => {
  setFullName(firstName + " " + lastName);
}, [firstName, lastName]);

// ✅ Good - calculate during render
const fullName = firstName + " " + lastName;
```

**Fix:** Delete the state and Effect. Calculate the value directly during render.

---

### 2. Filtered/Transformed Data (REMOVE or MEMO)

**Symptom:** Effect filters or transforms props into state

```jsx
// 🔴 Bad
const [visibleTodos, setVisibleTodos] = useState([]);
useEffect(() => {
  setVisibleTodos(getFilteredTodos(todos, filter));
}, [todos, filter]);

// ✅ Good - calculate during render
const visibleTodos = getFilteredTodos(todos, filter);

// ✅ Also good - memoize if expensive
const visibleTodos = useMemo(
  () => getFilteredTodos(todos, filter),
  [todos, filter]
);
```

**Fix:** Calculate during render. Use `useMemo` only if the calculation is expensive (>1ms).

---

### 3. Resetting State on Prop Change (REMOVE)

**Symptom:** Effect resets state when a prop changes

```jsx
// 🔴 Bad
function ProfilePage({ userId }) {
  const [comment, setComment] = useState("");
  useEffect(() => {
    setComment("");
  }, [userId]);
}

// ✅ Good - use key to reset
function ProfilePage({ userId }) {
  return <Profile userId={userId} key={userId} />;
}
```

**Fix:** Pass a `key` prop to force React to remount the component with fresh state.

---

### 4. Adjusting State on Prop Change (REFACTOR)

**Symptom:** Effect partially adjusts state when props change

```jsx
// 🔴 Bad
function List({ items }) {
  const [selection, setSelection] = useState(null);
  useEffect(() => {
    setSelection(null);
  }, [items]);
}

// ✅ Better - store ID, derive the object
function List({ items }) {
  const [selectedId, setSelectedId] = useState(null);
  const selection = items.find((item) => item.id === selectedId) ?? null;
}
```

**Fix:** Store minimal state (IDs, not objects). Derive the full value during render.

---

### 5. Event-Driven Logic (REMOVE)

**Symptom:** Effect runs logic that should happen on user action

```jsx
// 🔴 Bad
useEffect(() => {
  if (product.isInCart) {
    showNotification("Added to cart!");
  }
}, [product]);

// ✅ Good - in the event handler
function handleBuyClick() {
  addToCart(product);
  showNotification("Added to cart!");
}
```

**Fix:** Move the logic into the event handler that triggers the action.

---

### 6. POST Requests on User Action (REMOVE)

**Symptom:** Effect sends requests triggered by user interaction

```jsx
// 🔴 Bad
const [jsonToSubmit, setJsonToSubmit] = useState(null);
useEffect(() => {
  if (jsonToSubmit !== null) {
    post("/api/register", jsonToSubmit);
  }
}, [jsonToSubmit]);

function handleSubmit(e) {
  e.preventDefault();
  setJsonToSubmit({ firstName, lastName });
}

// ✅ Good - POST in handler
function handleSubmit(e) {
  e.preventDefault();
  post("/api/register", { firstName, lastName });
}
```

**Fix:** Make the request directly in the event handler.

---

### 7. Effect Chains (REMOVE)

**Symptom:** Multiple Effects that trigger each other via state updates

```jsx
// 🔴 Bad - cascading effects
useEffect(() => {
  if (card?.gold) setGoldCardCount((c) => c + 1);
}, [card]);

useEffect(() => {
  if (goldCardCount > 3) {
    setRound((r) => r + 1);
    setGoldCardCount(0);
  }
}, [goldCardCount]);

// ✅ Good - all logic in event handler
function handlePlaceCard(nextCard) {
  setCard(nextCard);
  if (nextCard.gold) {
    if (goldCardCount < 3) {
      setGoldCardCount(goldCardCount + 1);
    } else {
      setGoldCardCount(0);
      setRound(round + 1);
    }
  }
}
```

**Fix:** Calculate all state changes in the event handler. Derive what you can during render.

---

### 8. Notifying Parent of State Changes (REMOVE)

**Symptom:** Effect calls parent callback when local state changes

```jsx
// 🔴 Bad
function Toggle({ onChange }) {
  const [isOn, setIsOn] = useState(false);
  useEffect(() => {
    onChange(isOn);
  }, [isOn, onChange]);
}

// ✅ Good - call in handler
function Toggle({ onChange }) {
  const [isOn, setIsOn] = useState(false);
  function updateToggle(nextIsOn) {
    setIsOn(nextIsOn);
    onChange(nextIsOn);
  }
}

// ✅ Best - lift state up (controlled component)
function Toggle({ isOn, onChange }) {
  // Parent owns the state
}
```

**Fix:** Call the parent callback in the same event handler that updates state, or lift state up.

---

### 9. Passing Data to Parent (REMOVE)

**Symptom:** Child fetches data and passes it up via Effect

```jsx
// 🔴 Bad
function Child({ onFetched }) {
  const data = useSomeAPI();
  useEffect(() => {
    if (data) onFetched(data);
  }, [onFetched, data]);
}

// ✅ Good - parent fetches, passes down
function Parent() {
  const data = useSomeAPI();
  return <Child data={data} />;
}
```

**Fix:** Move data fetching to the parent. Data flows down, not up.

---

## When Effects ARE Appropriate

### ✅ Synchronizing with External Systems

- DOM manipulation (focus, scroll, measure)
- Non-React widgets (maps, charts, jQuery)
- Browser APIs (intersection observer, resize observer)
- WebSocket connections

### ✅ Analytics/Logging on Mount

```jsx
useEffect(() => {
  post("/analytics/event", { eventName: "page_view" });
}, []);
```

### ✅ Data Fetching (with cleanup)

```jsx
useEffect(() => {
  let ignore = false;
  fetchData(query).then((data) => {
    if (!ignore) setData(data);
  });
  return () => {
    ignore = true;
  };
}, [query]);
```

Consider using a data fetching library (TanStack Query, SWR) or framework instead.

### ✅ Subscriptions to External Stores

Prefer `useSyncExternalStore` over manual Effects:

```jsx
const isOnline = useSyncExternalStore(
  subscribe,
  () => navigator.onLine,
  () => true
);
```

---

## Refactoring Checklist

When you encounter a `useEffect`:

1. **What triggers it?** If a user action → move to event handler
2. **What does it do?** If it sets state derived from other state/props → calculate during render
3. **Does it call a parent callback?** → Call in event handler or lift state up
4. **Does it sync with external system?** → Keep it (this is valid)
5. **Is it part of a chain?** → Consolidate into event handler or derive during render

---

## Quick Replacements

| Pattern                                | Replace With                    |
| -------------------------------------- | ------------------------------- |
| `useEffect` + `setState` from props    | Direct calculation              |
| `useEffect` + `setState` filtered data | `useMemo` or direct calculation |
| `useEffect` to reset on prop change    | `key` prop                      |
| `useEffect` + parent callback          | Event handler                   |
| `useEffect` for user action            | Event handler                   |
| `useEffect` chain                      | Single event handler            |
| `useEffect` for external subscription  | `useSyncExternalStore`          |
