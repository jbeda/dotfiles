# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Installation

Run `./install` from the repo root. It symlinks files from `link/` and platform-specific directories (`darwin/link/` or `linux/link/`) into `$HOME`, backing up any pre-existing files to `~/.dotfiles-backups/{timestamp}/`. It also bootstraps two binaries if missing — `starship` (prompt) and `mise` (runtime versions) — via brew on macOS or their official installers into `~/.local/bin` on Linux, then runs `mise install` to realize the runtimes pinned in `config/mise/config.toml`.

There are no tests. Validate changes by sourcing the relevant script or opening a new shell session.

## Architecture

### Symlink Layer (`link/`, `darwin/link/`, `linux/link/`)

Files here are symlinked directly into `$HOME`. The install script detects the platform (Darwin or Linux) and processes both the generic `link/` and the platform-specific subdirectory. Platform-specific files override generic ones when both exist (e.g., `.gitconfig.platform` differs per OS for credential helpers).

### XDG Config Layer (`config/`, `darwin/config/`, `linux/config/`)

Trees here are mirrored into `~/.config`: directories are created as real
directories (`~/.config` is shared with unmanaged tools), and only leaf files
are symlinked (e.g. `darwin/config/ghostty/config` → `~/.config/ghostty/config`).
Platform subdirectories install only on that platform.

### Shell Startup Tiers

`.zprofile` sources `.zshrc` unconditionally, so `source/*.sh` runs in **non-interactive login shells** (`zsh -lc`, macOS launchd/GUI-spawned shells) too, not just interactive ones. That gives three tiers:

1. **Every zsh** (`zsh -c`, scripts, cron): `.zshenv` only. Keep it minimal — a handful of PATH entries (mise shims, `~/.local/bin`) that must exist in bare `zsh -c`. It is paid by every zsh spawn; do not add a composable source loop or anything slow. If it grows past a screenful, something belongs in a later tier.
2. **Login shells** (including non-interactive `zsh -lc`): `.zshenv` + the *unguarded* files in `source/` — PATH and environment (brew, go, mise, cloud SDKs, secrets, editor).
3. **Interactive shells**: everything, including files guarded with `[[ -o interactive ]] || return` — prompt, keybindings, completion, history, tmux, terminal integrations.

The contract for `source/*.sh`: **guarded = interactive-only UX; unguarded = environment, and must be safe (fast, no output, no ttys) when run non-interactively.** When adding a file, pick deliberately.

### Shell Script Modules (`source/`, `darwin/source/`, `linux/source/`)

`.zshrc` sources all `*.sh` files from `source/` (and the platform-specific source dir) in numeric order. Scripts are numbered to control load order:

- `10-15` — terminal/locale/Homebrew init (must run first, no deps)
- `40-42` — PATH construction and terminal integrations (iTerm2, Ghostty)
- `45-55` — environment setup: editors, Go, Node (via mise), AWS, GCloud, SSH agent, history, prompt
- `55` — keybindings
- `60` — zsh completion init (runs after PATH is set)
- `90` — PATH deduplication (runs last in setup)
- `99` — session messages (tmux indicators)

Add a new shell feature by creating a numbered `.sh` file in `source/`. Runtime versions (Node today; Go/Python could move here too) are managed by mise: `source/50_mise.sh` activates it, `config/mise/config.toml` pins the tools, and `./install` bootstraps the binary. Edit the pins in the repo file rather than running `mise use -g`, which can break the config symlink.

### Third-Party Submodules (`third_party/`)

- `dircolors-solarized` — solarized colors for `ls`/`grep` output

Initialize submodules with `git submodule update --init` after cloning.

### Local Overrides (not in repo)

- `~/.zsh.local` — sourced at end of `.zshrc` for machine-specific config
- `~/.secrets/` — directory of files sourced by `50_secrets.sh` for credentials
- `~/.gitconfig.local` — not referenced directly, but `.gitconfig` uses `.gitconfig.platform` for per-OS credential helpers

### Docker

The `Makefile` builds/pushes a container image (`gcr.io/jbeda-prod/dotfiles`) that installs these dotfiles into an Ubuntu base. Targets: `make build`, `make push`, `make run`, `make kube-run`.

## Pre-commit: strip ToolHive injections

ToolHive silently appends the following block to `link/.zshrc` when it launches — remove it before committing:

```
# Added by ToolHive UI - do not modify this block
export PATH="$HOME/.toolhive/bin:$PATH"
# End ToolHive UI
```

Before staging or committing any change in this repo, check `git diff link/.zshrc` (and the working-tree file) for this block and strip it. Do not commit it.
