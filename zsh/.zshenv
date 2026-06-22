# ~/.zshenv - Environment for all zsh invocations
# Keep this file minimal; it runs for login, interactive, and non-interactive shells.

# Ensure tool shims resolve correctly in automation and non-interactive shells.
if [[ -d "$HOME/.local/share/mise/shims" ]] && [[ ":$PATH:" != *":$HOME/.local/share/mise/shims:"* ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# Auto-trust project mise configs under these roots (no `mise trust` prompt).
# Must be an env var, not a config-file setting: mise resolves the symlinked
# global config to its dotfiles path, treats it as non-global, and ignores
# trusted_config_paths set there. Env vars are honored regardless of origin.
export MISE_TRUSTED_CONFIG_PATHS="$HOME/Code:$HOME/conductor"
