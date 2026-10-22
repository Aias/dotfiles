---
name: browser-and-1password
description: >
  Choose a browser for web tasks and read credentials from 1Password with `op`.
  Use before browser automation, a login in an isolated browser session, or any `op` call.
---

# Browsers and 1Password

## Choose an isolated browser

Use a session isolated from the user's own browser whenever it can do the job: the globally installed `agent-browser` CLI (`agent-browser skills get core` prints its version-matched guide), the harness's built-in browser, or a plain fetch when text is enough. These need no permission, including for pages behind a login. When an isolated session needs credentials, read them from 1Password with `op read` and pipe the password to `agent-browser auth save <name> --password-stdin` so it never appears in a command argument.

Dia is the user's primary browser and may be in active use. Ask before opening or navigating a Dia tab or resizing its window, whether through claude-in-chrome or computer use. Google Chrome is usually closed, so check which browser claude-in-chrome is connected to before acting, and never launch Chrome to get a connection.

## Read each 1Password value once

Every `op` call, including a search, asks the user for approval, so keep it to one call per credential per session. When a task needs the same value more than once, write it with a single `op read` into a temporary secrets or env file with owner-only permissions (`umask 077`) in the session's scratch directory, and have later commands and scripts load it from that file.

When the item isn't known, ask the user which one to use instead of searching vaults or accounts. When delegating, do the read yourself and pass subagents the file path. Never print or read the file's contents yourself. Delete the file when the task is done.
