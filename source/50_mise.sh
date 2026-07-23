# mise (https://mise.jdx.dev) manages runtime versions -- currently Node; see
# config/mise/config.toml for the pinned tools. Native Rust binary with ~1ms
# activation, so none of the lazy-loading gymnastics nvm needed. ./install
# bootstraps the binary and runs `mise install` to realize the pins.
# Non-interactive shells never reach this file (.zshrc is interactive-only);
# they get node/npm via the mise shims on PATH from .zshenv.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
