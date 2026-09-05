---
name: debug-agent
description: >-
  Use when a bug needs runtime evidence and source changes are authorized: the agent
  instruments code with NDJSON logs, reproduces, and fixes only what the logs prove.
  For read-only investigation with no instrumentation, use `/dig` instead.
global_category: Investigation
---

# Debug Mode

You are now in **DEBUG MODE**. You must debug with **runtime evidence**.

**Why this approach:** Fixes reasoned from code alone routinely miss the actual runtime cause. Debug from runtime evidence, and fix only what the logs prove.

**When to use `/dig` instead:** `/dig` is read-only investigation — no code mutations, no instrumentation. Use `/dig` when you only need to understand behavior or when the environment forbids modifying source. Use `/debug-agent` when you can modify code and need runtime evidence to support a fix.

<!-- @> Debug from runtime evidence, never code reasoning alone: instrument only when existing evidence is insufficient, reproduce, cite log lines to confirm/reject each hypothesis, and fix only what the logs prove -->

**Workflow:** Use existing runtime evidence (a failing test, existing logs, an observed API response) to distinguish plausible causes. Add targeted instrumentation only when the evidence is insufficient and source changes are authorized. Follow the daemon protocol below when using the daemon. Reproduce with the cheapest authorized method and reuse it for every later iteration: run an existing failing test, or write an ad hoc script tailored to the runtime (drive the browser via `/agent-browser` for frontend bugs, a Node, Python, or shell script for backend bugs). Ask the user to reproduce only when their participation is necessary, with numbered steps and a reminder to restart anything that caches instrumented files. Evaluate each hypothesis against cited log lines: CONFIRMED requires a log value only that hypothesis predicts; if a competing hypothesis would produce the same line, mark it INCONCLUSIVE and add a discriminating log. Fix only with cited proof, verify the fix against the observed failure with a before/after comparison, preserve the evidence needed for that comparison, then remove temporary instrumentation. Successful automated verification does not require an additional user confirmation. When logs reject a hypothesis, revert the code changes made for it; when every hypothesis is rejected, form new ones from other subsystems and instrument those. Close with a one or two line summary of the cause and the fix.

**Constraints:**

- Rely on runtime information plus code, never code alone.
- Keep instrumentation in place until post-fix verification logs prove success.
- Iteration is expected; taking longer with more data yields more precise fixes.
<!-- @> Never instrument or mutate production. Debug locally, in staging, or in a reproducible environment — never add log lines to or write data into production services, even temporarily -->
- **Never instrument or mutate production.** Debug locally, in staging, or in another reproducible environment. Adding log lines to production services or writing to production data to "see what's happening" is forbidden — even temporarily, even with the intent to revert. A bug observed in production is still a code issue; reproduce the conditions in a safe environment and instrument there.

---

## Logging

### Step 0: Start the logging server before instrumenting

Run the debug server in **daemon mode** before adding instrumentation. The `--daemon` flag starts the server in the background and exits immediately with the server info — no backgrounding or `&` required.

```bash
npx debug-agent --daemon
```

The command prints a single JSON line to stdout and exits:

```json
{
  "sessionId": "a1b2c3",
  "port": 54321,
  "endpoint": "http://127.0.0.1:54321/ingest/a1b2c3",
  "logPath": "/tmp/debug-agent/debug-a1b2c3.log"
}
```

Capture and remember these values:

- **Server endpoint**: The `endpoint` value (the HTTP endpoint URL where logs will be sent via POST requests)
- **Log path**: The `logPath` value (NDJSON logs are written here)
- **Session ID**: The `sessionId` value (unique identifier for this debug session)

If the server fails to start, stop and inform the user; do not instrument without a valid logging configuration.

- The server is idempotent — if one is already running, it returns the existing server's info instead of starting a duplicate.
- You do not need to pre-create the log file; it will be created automatically when your instrumentation first writes to it.

### Step 1: Understand the log format

- Logs are written in **NDJSON format** (one JSON object per line) to the file specified by the **log path**.
- For JavaScript/TypeScript, logs are sent via a POST request to the **server endpoint** during runtime, and the logging server writes these as NDJSON lines to the **log path** file.
- For other languages (Python, Go, Rust, Java, C/C++, Ruby, etc.), you should prefer writing logs directly by appending NDJSON lines to the **log path** using the language's standard library file I/O.

Example log entry:

```json
{
  "sessionId": "a1b2c3",
  "id": "log_1733456789_abc",
  "timestamp": 1733456789000,
  "location": "test.js:42",
  "message": "User score",
  "data": { "userId": 5, "score": 85 },
  "runId": "run1",
  "hypothesisId": "A"
}
```

### Step 2: Insert instrumentation logs

- In **JavaScript/TypeScript files**, use this one-line fetch template (replace `ENDPOINT` and `SESSION_ID` with values from Step 0), even if filesystem access is available:

```
fetch('ENDPOINT',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({sessionId:'SESSION_ID',location:'file.js:LINE',message:'desc',data:{k:v},timestamp:Date.now()})}).catch(()=>{});
```

- In **non-JavaScript languages** (Python, Go, Rust, Java, C, C++, Ruby), instrument by opening the **log path** in append mode using standard library file I/O, writing a single NDJSON line with your payload, and then closing the file. Keep these snippets as tiny and compact as possible (ideally one line, or just a few).

- Place the minimum number of logs that can confirm or reject every open hypothesis; a single well-placed log may be enough when the issue is localized, and a growing count is a sign to narrow the hypotheses first.

- Choose log placements from these categories as relevant to your hypotheses:
  - Function entry with parameters
  - Function exit with return values
  - Values BEFORE critical operations
  - Values AFTER critical operations
  - Branch execution paths (which if/else executed)
  - Suspected error/edge case values
  - State mutations and intermediate values

- Each log must map to at least one hypothesis (include `hypothesisId` in payload).
- Use this payload structure: `{sessionId, runId, hypothesisId, location, message, data, timestamp}`
- Wrap each debug log in a collapsible code region using language-appropriate syntax (`// #region debug log` and `// #endregion` for JS/TS). The markers keep the editor clean and make cleanup deterministic.
- Never log secrets (tokens, passwords, API keys, PII).

### Step 3: Clear the previous log file before each run

- Send a `DELETE` request to the **server endpoint** to clear the log file before each run. For example: `curl -X DELETE ENDPOINT` (replace `ENDPOINT` with the endpoint value from Step 0).
- This ensures clean logs for the new run without mixing old and new data.
- Clearing the log file is NOT the same as removing instrumentation; do not remove any debug logs from code here.
- Only clear your own session's logs (via your endpoint from Step 0). Never delete, modify, or overwrite log files belonging to other debug sessions.

### Step 4: Read logs after the run

- After the reproduction completes (do not ask the user to type "done"), read the file at the **log path**.
- The log file will contain NDJSON entries (one JSON object per line) from your instrumentation.
- Analyze these logs to evaluate your hypotheses and identify the root cause.
- If the log file is empty or missing, do not conclude the instrumentation is broken. First confirm the instrumented path actually executed: a path behind a lazy-mounted component, a deferred import, or an interaction gate (click, route change, feature flag) never runs on a plain reload, so correct instrumentation still emits nothing. Drive the trigger, then re-read. Only after confirming the path ran should you treat an empty log as a failed reproduction and run it again.
- **For frontend bugs**, supplement the NDJSON log with the browser MCP attached to the live browser (claude-in-chrome in Claude Code, Chrome DevTools MCP in Codex) — console messages, network requests, and performance traces are runtime evidence too. Cite MCP findings with the same specificity as log lines (exact message, request URL, stack frame) rather than paraphrasing.

### Step 5: Keep logs during fixes

- When implementing a fix, keep the debug logs in place; they are the verification run's evidence.
- Tag verification runs with `runId="post-fix"` to distinguish them from initial debugging runs.
- Remove logs only after a successful post-fix verification run (log-based proof) or an explicit user request.

---

<!-- @> No setTimeout/sleep/artificial delays as a "fix" — use proper reactivity, events, and lifecycles -->
## Critical reminders

- Never use `setTimeout`, `sleep`, or artificial delays as a "fix"; use proper reactivity, events, and lifecycles.
- Verification requires before/after log comparison with cited log lines; do not claim success without log proof.
- Clear logs by sending a DELETE request to the server endpoint; do not create the log file manually.
- Only touch the log file at the exact path from Step 0.
- **Remove code changes from rejected hypotheses:** When logs prove a hypothesis wrong, revert the code changes made for that hypothesis. Do not let defensive guards, speculative fixes, or unproven changes accumulate. Only keep modifications that are supported by runtime evidence.
- Prefer reusing existing architecture, patterns, and utilities; avoid overengineering. Make fixes precise, targeted, and as small as possible while maximizing impact.

## Cleanup

When it is time to remove instrumentation (after verified fix or user request):

1. Search all files for `#region debug log` markers (e.g., grep/ripgrep for `#region debug log`)
2. For each match, delete everything from the `#region debug log` line through its corresponding `#endregion` line (inclusive)
3. Grep again to verify zero markers remain
4. Run `git diff` to review all changes — confirm only your intentional fix remains and no stray debug code was missed

---

## Server API reference

| Method                      | Effect                                      |
| --------------------------- | ------------------------------------------- |
| `POST /ingest/:sessionId`   | Append JSON body as NDJSON line to log file |
| `GET /ingest/:sessionId`    | Read full log file contents                 |
| `DELETE /ingest/:sessionId` | Clear the log file                          |
