---
name: debugger
description: >
  Use when debugging JS/TS—"debug this", "can't figure out why", structured logging, `/debugger`,
  hypothesis-driven investigation, or "instrument the code". Triggers on repro steps, flaky behavior,
  root-cause analysis before guessing fixes. Hypothesis-led instrumentation and log review.
global_category: Debugging
---

<!-- @> Evidence over intuition: no fixes until logs confirm root cause. Minimal instrumentation -->

# Debugger

Systematic debugging through hypothesis generation, targeted instrumentation, and runtime log analysis. Never guess at fixes — gather evidence first.

## Principles

- **Evidence over intuition.** Do not propose fixes until logs confirm a root cause.
- **Minimal instrumentation.** Fewest debug statements that distinguish between hypotheses.
- **Clean exit.** All instrumentation is temporary and removable with a single grep.
- **User controls reproduction.** The agent instruments; the user triggers the bug.

## Workflow

### Step 0: Receive Bug Report

Gather from the user (skip anything already provided):

1. What happens (observed behavior)
2. What should happen (expected behavior)
3. How to reproduce (steps, commands, URL)
4. When it started (recent change? always broken? intermittent?)

### Step 1: Explore and Hypothesize

Read relevant source files. Trace the code path from entry point to observed behavior.

Generate **3-5 hypotheses**. Each must be:

- **Specific** — names a file, function, or code path
- **Falsifiable** — describes what logs would show if correct vs incorrect
- **Ranked** — by likelihood based on code reading

Present to the user:

```
Hypotheses (Round 1):

1. [Most likely] Race condition in `src/auth.ts:validateToken` — the token
   refresh fires before the previous request completes. If true: logs show
   overlapping refresh calls with different token values.

2. Cache TTL in `src/cache.ts:get` expires mid-request...
   If true: logs show cache miss immediately after a cache set.

3. ...
```

Wait for user confirmation before instrumenting. User may add, remove, or reorder.

### Step 2: Start Debug Server

Start the log collection server in the background:

```bash
python3 <skill-path>/scripts/debug-server.py --port 8765 --round 1 &
```

The server auto-selects the next available port if 8765 is taken (tries up to 8770). Logs go to `/tmp/debug-logs-{pid}/`. Note the log directory path from server output.

Health check:

```bash
curl -s http://127.0.0.1:8765/health
```

### Step 3: Instrument Code

Add debug logging to the codebase. Rules:

1. **Region markers.** Wrap every debug block in:

   ```js
   // #region DEBUG
   <debug code>
   // #endregion DEBUG
   ```

2. **Helper function.** Add once per instrumented file, at the top, inside region markers (see Instrumentation Patterns below).

3. **Multiple regions per file.** Add as many `#region DEBUG` blocks as needed throughout a file — one per instrumentation point.

4. **Hypothesis tagging.** Each debug call includes the hypothesis number:

   ```js
   // #region DEBUG
   __debug(1, "token at validation entry", {
     tokenPrefix: token.substring(0, 8),
   });
   // #endregion DEBUG
   ```

5. **Data safety.** Never log full secrets, passwords, tokens, or PII. Truncate or hash sensitive values.

6. **Observation only.** Debug statements must not alter control flow, catch exceptions, or change return values.

### Step 4: Reproduce

Ask the user to reproduce the bug:

> "Instrumentation is in place for Round {N}. Reproduce the bug and tell me when done."

Do not reproduce the bug unless the user provides a test command and asks. Wait for "reproduced", "done", or similar.

### Step 5: Analyze Logs

Read the round log file:

```bash
curl -s http://127.0.0.1:{port}/logs/{round}
```

Or read directly from the path printed at server startup.

For each hypothesis, determine:

- **CONFIRMED** — logs show the predicted pattern. State the evidence.
- **REJECTED** — logs contradict the prediction. State expected vs observed.
- **INCONCLUSIVE** — not enough data. State what additional instrumentation is needed.

Present analysis:

```
Round {N} Analysis:

H1 [CONFIRMED]: Logs show two concurrent refresh calls at T1 and T2,
   with token values diverging at line 47.

H2 [REJECTED]: Cache TTL was 300s, request completed in 12ms. No miss.

H3 [INCONCLUSIVE]: Code path not hit during reproduction. Need to add
   instrumentation to error handler at src/api.ts:89.
```

### Step 6: Fix or Refine

**If a hypothesis is confirmed:**

1. Propose a targeted fix. Explain root cause and fix concretely.
2. Wait for user approval before applying.
3. Ask user to verify: "Fix applied. Reproduce the original scenario — is the bug resolved?"
4. User says **"fixed"** → Step 7.
5. User says **"not fixed"** → treat as inconclusive, refine hypotheses, back to Step 1.

**If inconclusive:**

1. Generate refined hypotheses based on log evidence.
2. Increment round number. Restart server with `--round {N+1}` or start fresh.
3. Add new instrumentation; remove statements for rejected hypotheses.
4. Back to Step 4.

**Max 5 rounds.** If no confirmed hypothesis after 5 rounds, pause and reassess with the user. Suggest alternatives: `git bisect`, minimal reproduction, or pair debugging.

### Step 7: Cleanup

When the user confirms the bug is fixed:

1. **Remove all instrumentation.** Find files with debug regions:

   ```bash
   rg -l "#region DEBUG" .
   ```

   Delete every block between `// #region DEBUG` and `// #endregion DEBUG` (inclusive).

2. **Stop the debug server:**

   ```bash
   kill $(lsof -ti:8765) 2>/dev/null
   ```

3. **Verify cleanup:**

   ```bash
   rg "#region DEBUG" .
   ```

   Must return zero results.

4. **Present summary:**
   ```
   Debug Summary:
   - Bug: [one-line description]
   - Root cause: [file:line, one-line description]
   - Fix: [what changed]
   - Rounds: {N}
   - Files modified: [list]
   ```

## Instrumentation Patterns (JS/TS)

### ESM Helper

```js
// #region DEBUG
const __DEBUG_PORT = process.env.DEBUG_PORT || 8765;
async function __debug(hypothesis, message, data) {
  try {
    await fetch(`http://127.0.0.1:${__DEBUG_PORT}/log`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        hypothesis,
        message,
        data,
        file: new URL(import.meta.url).pathname,
      }),
    });
  } catch {}
}
// #endregion DEBUG
```

### CJS Helper

```js
// #region DEBUG
const __DEBUG_PORT = process.env.DEBUG_PORT || 8765;
function __debug(hypothesis, message, data) {
  try {
    const http = require("http");
    const payload = JSON.stringify({
      hypothesis,
      message,
      data,
      file: __filename,
    });
    const req = http.request({
      hostname: "127.0.0.1",
      port: __DEBUG_PORT,
      path: "/log",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(payload),
      },
    });
    req.on("error", () => {});
    req.end(payload);
  } catch {}
}
// #endregion DEBUG
```

### Browser Helper

```js
// #region DEBUG
function __debug(hypothesis, message, data) {
  fetch("http://127.0.0.1:8765/log", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      hypothesis,
      message,
      data,
      file: location.pathname,
    }),
  }).catch(() => {});
}
// #endregion DEBUG
```

### File-Append Fallback

For environments without localhost HTTP (sandboxed workers, edge runtimes):

```js
// #region DEBUG
const __fs = require("fs");
function __debug(hypothesis, message, data) {
  try {
    __fs.appendFileSync(
      "/tmp/debug-logs/round-1.log",
      JSON.stringify({
        ts: Date.now(),
        hypothesis,
        message,
        data,
        file: __filename,
      }) + "\n",
    );
  } catch {}
}
// #endregion DEBUG
```

Update the round number in the file path for each round.

### Usage (multiple regions in one file)

```js
import { validateToken } from "./auth";

// #region DEBUG
const __DEBUG_PORT = process.env.DEBUG_PORT || 8765;
async function __debug(hypothesis, message, data) {
  /* ... */
}
// #endregion DEBUG

export async function handleRequest(req) {
  const token = req.headers.authorization;

  // #region DEBUG
  await __debug(1, "token at entry", { length: token?.length });
  // #endregion DEBUG

  const result = await validateToken(token);

  // #region DEBUG
  await __debug(1, "validation result", { valid: result.valid });
  await __debug(2, "cache state after validation", {
    cached: result.fromCache,
  });
  // #endregion DEBUG

  return result;
}
```

## Edge Cases

- **Server already running:** Check `curl -s http://127.0.0.1:8765/health` before starting. If responsive, reuse or restart (ask user).
- **Pause and resume:** Instrumentation persists in code. On resume, check for existing `#region DEBUG` blocks and `/tmp/debug-logs-*/` directories.
- **Multiple bugs:** Handle one at a time. Note secondary bugs and ask user whether to switch.
- **Test-driven repro:** If reproducible via a test command, offer to run it directly instead of asking the user. Confirm first.
- **No hypotheses confirmed:** After exhausting ideas, say so honestly. Suggest `git bisect`, minimal repro, or checking external dependencies.
