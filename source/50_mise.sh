# mise (https://mise.jdx.dev) manages runtime versions -- currently Node; see
# config/mise/config.toml for the pinned tools. Native Rust binary with ~1ms
# activation, so none of the lazy-loading gymnastics nvm needed. ./install
# bootstraps the binary and runs `mise install` to realize the pins.
if command -v mise >/dev/null 2>&1; then
  if [[ -o interactive ]]; then
    eval "$(mise activate zsh)"
  else
    # Non-interactive: put the static shims on PATH so scripts find node/npm.
    eval "$(mise activate zsh --shims)"
  fi
fi
