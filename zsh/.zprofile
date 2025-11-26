# ~/.zprofile - Login shell configuration
# Runs once on login (not for every new terminal)

# ─────────────────────────────────────────────────────────────
# Homebrew
# ─────────────────────────────────────────────────────────────
# Only run Homebrew shellenv in interactive shells,
# and only if brew actually exists.
# https://github.com/openai/codex/issues/4620#issuecomment-3559735331
if [[ $- == *i* ]] && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ─────────────────────────────────────────────────────────────
# PATH modifications
# ─────────────────────────────────────────────────────────────
# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Postgres.app CLIs
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

# fnm (Node version manager) - added to PATH for lazy loading
export PATH="$HOME/.local/share/fnm:$PATH"

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# ─────────────────────────────────────────────────────────────
# Environment variables
# ─────────────────────────────────────────────────────────────
export HOMEBREW_NO_ENV_HINTS=1

# Local environment (paths, exports)
[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# ─────────────────────────────────────────────────────────────
# Secrets (API keys - not tracked in version control)
# ─────────────────────────────────────────────────────────────
[[ -r "$HOME/.secrets" ]] && source "$HOME/.secrets"
