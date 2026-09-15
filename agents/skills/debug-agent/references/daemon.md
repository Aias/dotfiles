# Debug-agent daemon

Use this protocol when the investigation needs a shared HTTP log sink. Existing logs, test output, and debugger tools can also provide runtime evidence.

Start the daemon with `bunx debug-agent --daemon`. Capture the returned `sessionId`, `endpoint`, and `logPath`. Confirm the endpoint works before adding code that depends on it.

Send JSON to the returned endpoint with fields that identify the run, hypothesis, source location, and observed values. The daemon writes one JSON object per line to `logPath`. Use distinct run IDs for the failing reproduction and post-fix verification.

| Request | Effect |
| --- | --- |
| `POST` to the session endpoint | Append a JSON log entry |
| `GET` from the session endpoint | Read the session log |
| `DELETE` from the session endpoint | Clear the session log |

Preserve evidence needed for the comparison before clearing this investigation's session log. Leave other sessions' logs untouched.

If no entries appear, verify that the instrumented path executed and the request reached the endpoint. A mounted component, deferred import, or gated interaction may require a specific trigger.

Keep instrumentation identifiable through named helpers or bindings so it can be removed completely. After verification, remove those additions and inspect the diff for remaining instrumentation. Use the tool's documented shutdown command to stop a daemon started solely for this investigation.
