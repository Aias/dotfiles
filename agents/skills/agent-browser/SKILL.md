---
name: agent-browser
description: >
  Use when programmatic browser work—navigate, fill forms, click, screenshots, scrape/extract data,
  login flows, or E2E-style checks without manual driving. Triggers on "open this site", "automate
  the browser", "take a screenshot", "test in the browser", headless UI verification. Uses agent-browser.
allowed-tools: Bash(npx agent-browser:*), Bash(agent-browser:*)
---

# Browser Automation with agent-browser

agent-browser is an open-source CLI by Vercel Labs ([vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser)).

## Core Workflow

Every browser automation follows this pattern:

1. **Navigate**: `agent-browser open <url>`
2. **Snapshot**: `agent-browser snapshot -i` (get element refs like `@e1`, `@e2`)
3. **Interact**: Use refs to click, fill, select
4. **Re-snapshot**: After navigation or DOM changes, get fresh refs

```bash
agent-browser open https://example.com/form
agent-browser snapshot -i
# Output: @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Submit"

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i  # Check result
```

## Command Chaining

Commands can be chained with `&&` in a single shell invocation. The browser persists between commands via a background daemon, so chaining is safe and more efficient than separate calls.

```bash
# Chain open + wait + snapshot in one call
agent-browser open https://example.com && agent-browser wait --load networkidle && agent-browser snapshot -i

# Chain multiple interactions
agent-browser fill @e1 "user@example.com" && agent-browser fill @e2 "password123" && agent-browser click @e3

# Navigate and capture
agent-browser open https://example.com && agent-browser wait --load networkidle && agent-browser screenshot page.png
```

**When to chain:** Use `&&` when you don't need to read the output of an intermediate command before proceeding (e.g., open + wait + screenshot). Run commands separately when you need to parse the output first (e.g., snapshot to discover refs, then interact using those refs).

## Essential Commands

```bash
# Navigation
agent-browser open <url>              # Navigate (aliases: goto, navigate)
agent-browser back                    # Go back in history
agent-browser forward                 # Go forward in history
agent-browser reload                  # Reload current page
agent-browser close                   # Close browser

# Snapshot (auto-traverses iframes)
agent-browser snapshot -i             # Interactive elements with refs (recommended; includes cursor-interactive elements)
agent-browser snapshot -s "#selector" # Scope to CSS selector

# Interaction (use @refs from snapshot)
agent-browser click @e1               # Click element
agent-browser click @e1 --new-tab     # Click and open in new tab
agent-browser dblclick @e1            # Double-click element
agent-browser fill @e2 "text"         # Clear and type text
agent-browser type @e2 "text"         # Type without clearing
agent-browser select @e1 "option"     # Select dropdown option
agent-browser check @e1               # Check checkbox
agent-browser hover @e1               # Hover (for dropdowns, menus, tooltips)
agent-browser press Enter             # Press key (also: Control+a, Shift, etc.)
agent-browser keyboard type "text"    # Type at current focus (no selector)
agent-browser clipboard read          # Read clipboard content
agent-browser clipboard write "text"  # Write text to clipboard
agent-browser clipboard copy          # Trigger Ctrl+C
agent-browser clipboard paste         # Trigger Ctrl+V
agent-browser scroll down 500         # Scroll page (up/down/left/right)
agent-browser scroll down 500 --selector "div.content"  # Scroll within container
agent-browser drag @e1 @e2            # Drag and drop
agent-browser upload @e1 ./file.pdf   # Upload file(s) to file input

# Get information
agent-browser get text @e1            # Get element text
agent-browser get html @e1            # Get innerHTML
agent-browser get value @e1           # Get input value
agent-browser get attr @e1 href       # Get attribute value
agent-browser get url                 # Get current URL
agent-browser get title               # Get page title
agent-browser get count ".item"       # Count matching elements
agent-browser get box @e1             # Get bounding box (x, y, width, height)

# Check element state
agent-browser is visible @e1          # Check if visible
agent-browser is enabled @e1          # Check if enabled (not disabled)
agent-browser is checked @e1          # Check if checkbox/radio is checked

# Wait
agent-browser wait @e1                # Wait for element
agent-browser wait --load networkidle # Wait for network idle
agent-browser wait --url "**/page"    # Wait for URL pattern
agent-browser wait --text "Success"   # Wait for text to appear
agent-browser wait --fn "window.ready" # Wait for JS condition
agent-browser wait 2000               # Wait milliseconds

# Tabs
agent-browser tab list                # List all open tabs
agent-browser tab new [url]           # Open new tab
agent-browser tab <index>             # Switch to tab by index
agent-browser tab close [index]       # Close tab (current if no index)

# Dialogs
agent-browser dialog accept [text]    # Accept alert/confirm/prompt
agent-browser dialog dismiss          # Dismiss/cancel dialog

# Downloads
agent-browser download @e1 ./file.pdf          # Click element to trigger download
agent-browser wait --download ./output.zip     # Wait for any download to complete
agent-browser --download-path ./downloads open <url>  # Set default download directory

# Capture
agent-browser screenshot              # Screenshot to temp dir
agent-browser screenshot --full       # Full page screenshot (--full is per-command, not global)
agent-browser screenshot --annotate   # Annotated screenshot with numbered element labels
agent-browser screenshot --screenshot-dir ./caps --screenshot-format jpeg --screenshot-quality 80
agent-browser pdf output.pdf          # Save as PDF

# Debugging
agent-browser console                 # View browser console output
agent-browser errors                  # View JavaScript errors
agent-browser highlight @e1           # Highlight element visually
agent-browser inspect                 # Open Chrome DevTools for active page
agent-browser get cdp-url             # Get CDP WebSocket URL for external tools

# Network capture
agent-browser network har start                      # Start capturing network traffic (HAR 1.2)
agent-browser network har stop [output.har]          # Stop and save HAR (temp dir if no path)

# Batch execution
agent-browser batch --json < commands.json           # Execute commands from stdin (JSON array of string arrays)
agent-browser batch --bail < commands.json           # Stop on first error

# Diff (compare page states)
agent-browser diff snapshot                          # Compare current vs last snapshot
agent-browser diff snapshot --baseline before.txt    # Compare current vs saved file
agent-browser diff screenshot --baseline before.png  # Visual pixel diff
agent-browser diff url <url1> <url2>                 # Compare two pages
agent-browser diff url <url1> <url2> --screenshot    # With visual comparison
```

For the full command reference including mouse control, network interception, cookies/storage, frames, and browser settings, see [references/commands.md](references/commands.md).

## Common Patterns

### Form Submission

```bash
agent-browser open https://example.com/signup
agent-browser snapshot -i
agent-browser fill @e1 "Jane Doe"
agent-browser fill @e2 "jane@example.com"
agent-browser select @e3 "California"
agent-browser check @e4
agent-browser click @e5
agent-browser wait --load networkidle
```

### Authentication

For quick re-login without piping passwords through the model, use **`agent-browser auth`** (CLI-stored credentials):

```bash
echo "pass" | agent-browser auth save github --url https://github.com/login --username user --password-stdin
agent-browser auth login github
```

For manual login flows, save and restore state:

```bash
# After completing login...
agent-browser state save auth.json
# Later:
agent-browser state load auth.json
```

Use `--session-name myapp` to auto-persist cookies/localStorage across browser restarts. Use `--profile ./browser-data` for a persistent browser profile (survives `close`). See [references/authentication.md](references/authentication.md) for OAuth, 2FA, and advanced flows.

### Data Extraction

```bash
agent-browser open https://example.com/products
agent-browser snapshot -i
agent-browser get text @e5           # Get specific element text
agent-browser get text body > page.txt  # Get all page text

# JSON output for parsing
agent-browser snapshot -i --json
agent-browser get text @e1 --json
```

### Connect to Existing Chrome

```bash
agent-browser --auto-connect open https://example.com   # Auto-discover running Chrome
agent-browser --cdp 9222 snapshot                        # Or connect via explicit CDP port
```

### Color Scheme (Dark Mode)

```bash
agent-browser --color-scheme dark open https://example.com   # Via flag
agent-browser set media dark                                  # During session
```

### Visual Browser (Debugging)

```bash
agent-browser --headed open https://example.com  # Or AGENT_BROWSER_HEADED=1
agent-browser highlight @e1
agent-browser inspect                             # Open Chrome DevTools
agent-browser record start demo.webm
agent-browser record stop
```

### Local Files (PDFs, HTML)

```bash
agent-browser --allow-file-access open file:///path/to/document.pdf
agent-browser screenshot output.png
```

### iOS Simulator (Mobile Safari)

```bash
agent-browser device list
agent-browser -p ios --device "iPhone 16 Pro" open https://example.com
agent-browser -p ios snapshot -i
agent-browser -p ios tap @e1
agent-browser -p ios swipe up
agent-browser -p ios screenshot mobile.png
agent-browser -p ios close
```

**Requirements:** macOS with Xcode, Appium (`npm install -g appium && appium driver install xcuitest`).

## Security

All security features are opt-in. Configure via environment variables:

```bash
AGENT_BROWSER_CONTENT_BOUNDARIES=1            # Wrap page output in boundary markers (helps LLMs distinguish tool vs page content)
AGENT_BROWSER_ALLOWED_DOMAINS="*.example.com" # Restrict navigation to trusted domains
AGENT_BROWSER_ACTION_POLICY=./policy.json     # Gate destructive actions (e.g. {"default":"deny","allow":["navigate","snapshot","click"]})
AGENT_BROWSER_MAX_OUTPUT=50000                # Truncate page output to prevent context flooding
```

## Diffing (Verifying Changes)

Use `diff snapshot` after performing an action to verify it had the intended effect:

```bash
agent-browser snapshot -i          # Take baseline
agent-browser click @e2            # Perform action
agent-browser diff snapshot        # See what changed (+ additions, - removals)
```

For visual regression: `agent-browser diff screenshot --baseline before.png` produces a diff image with changed pixels highlighted. For cross-environment comparison: `agent-browser diff url <url1> <url2> --screenshot`.

## Timeouts and Slow Pages

Default timeout is 25 seconds (override with `AGENT_BROWSER_DEFAULT_TIMEOUT` in ms). For slow pages, use explicit waits after `open`:

```bash
agent-browser wait --load networkidle   # Wait for network to settle
agent-browser wait "#content"           # Wait for specific element
agent-browser wait --fn "window.ready"  # Wait for JS condition
```

## Session Management and Cleanup

Use named sessions (`--session <name>`) when running multiple automations concurrently. Always close sessions when done to avoid leaked processes:

```bash
agent-browser --session agent1 open site-a.com
agent-browser --session agent1 close
```

If a previous session wasn't closed properly, `agent-browser close` cleans up the daemon. Use `--idle-timeout` (e.g., `10s`, `3m`, `1h`) or `AGENT_BROWSER_IDLE_TIMEOUT_MS` for automatic daemon shutdown. See [references/session-management.md](references/session-management.md) for parallel sessions, state persistence, and concurrent scraping.

## Ref Lifecycle (Important)

Refs (`@e1`, `@e2`, etc.) are invalidated when the page changes. Always re-snapshot after:

- Clicking links or buttons that navigate
- Form submissions
- Dynamic content loading (dropdowns, modals)

```bash
agent-browser click @e5              # Navigates to new page
agent-browser snapshot -i            # MUST re-snapshot
agent-browser click @e1              # Use new refs
```

## Annotated Screenshots (Vision Mode)

Use `--annotate` to take a screenshot with numbered labels overlaid on interactive elements. Each label `[N]` maps to ref `@eN`. This also caches refs, so you can interact with elements immediately without a separate snapshot.

```bash
agent-browser screenshot --annotate
# Output includes the image path and a legend:
#   [1] @e1 button "Submit"
#   [2] @e2 link "Home"
#   [3] @e3 textbox "Email"
agent-browser click @e2              # Click using ref from annotated screenshot
```

Use annotated screenshots when:

- The page has unlabeled icon buttons or visual-only elements
- You need to verify visual layout or styling
- Canvas or chart elements are present (invisible to text snapshots)
- You need spatial reasoning about element positions

## Semantic Locators (Alternative to Refs)

When refs are unavailable or unreliable, use semantic locators:

```bash
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find role button click --name "Submit"
agent-browser find placeholder "Search" type "query"
agent-browser find testid "submit-btn" click
```

## JavaScript Evaluation (eval)

Use `eval` to run JavaScript in the browser. Use `--stdin` with heredoc for anything beyond simple expressions — shell quoting corrupts nested quotes, backticks, and `$()`:

```bash
agent-browser eval 'document.title'                    # Simple: single quotes OK
agent-browser eval --stdin <<'EVALEOF'                  # Complex: use heredoc
JSON.stringify(Array.from(document.querySelectorAll("a")).map(a => a.href))
EVALEOF
agent-browser eval -b "$(echo -n 'expression' | base64)"  # Or base64
```

## Configuration

Persistent settings via `agent-browser.json` in project root or `~/.agent-browser/config.json`. Priority: user config < project config < env vars < CLI flags. All CLI options map to camelCase keys. Use `--ignore-https-errors` for dev environments with self-signed certificates.

## Reference Documentation

- [references/commands.md](references/commands.md) — Full command reference with all options
- [references/snapshot-refs.md](references/snapshot-refs.md) — Ref lifecycle, invalidation rules, troubleshooting
- [references/session-management.md](references/session-management.md) — Parallel sessions, state persistence, concurrent scraping
- [references/authentication.md](references/authentication.md) — Login flows, OAuth, 2FA handling, state reuse
- [references/video-recording.md](references/video-recording.md) — Recording workflows for debugging and documentation
- [references/profiling.md](references/profiling.md) — Chrome DevTools profiling for performance analysis
- [references/proxy-support.md](references/proxy-support.md) — Proxy configuration, geo-testing, rotating proxies

## Browser Engines

agent-browser uses a native Rust daemon that communicates with Chrome directly via CDP. Auth cookies persist across browser restarts.

```bash
# Use Lightpanda browser engine (alternative to Chrome)
agent-browser --engine lightpanda open example.com
# Or: export AGENT_BROWSER_ENGINE=lightpanda
```

Supported engines: Chrome/Chromium/Brave (auto-discovered), Safari (via WebDriver), and Lightpanda.
