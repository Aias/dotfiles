# ~/.zshenv - Environment for all zsh invocations
# Keep this file minimal; it runs for login, interactive, and non-interactive shells.

# Ensure tool shims resolve correctly in automation and non-interactive shells.
if [[ -d "$HOME/.local/share/mise/shims" ]] && [[ ":$PATH:" != *":$HOME/.local/share/mise/shims:"* ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi
