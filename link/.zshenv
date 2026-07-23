# Sourced by every zsh -- interactive, scripts, `zsh -c`, cron, ssh remote
# commands. Keep it minimal: PATH bits that must exist everywhere, nothing
# slow, nothing interactive.

# mise shims so non-interactive shells find node/npm/etc. Interactive shells
# put the real tool paths ahead of these via `mise activate` (source/50_mise.sh).
[[ -d ~/.local/share/mise/shims ]] && path=(~/.local/share/mise/shims $path)

# Home-dir binaries (mise, starship, ...) for shells that skip .zprofile.
[[ -d ~/.local/bin ]] && path=(~/.local/bin $path)
