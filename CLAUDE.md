# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Installation

Run `./install` from the repo root. It symlinks files from `link/` and platform-specific directories (`darwin/link/` or `linux/link/`) into `$HOME`, backing up any pre-existing files to `~/.dotfiles-backups/{timestamp}/`.

There are no tests. Validate changes by sourcing the relevant script or opening a new shell session.

## Architecture

### Symlink Layer (`link/`, `darwin/link/`, `linux/link/`)

Files here are symlinked directly into `$HOME`. The install script detects the platform (Darwin or Linux) and processes both the generic `link/` and the platform-specific subdirectory. Platform-specific files override generic ones when both exist (e.g., `.gitconfig.platform` differs per OS for credential helpers).

### Shell Script Modules (`source/`, `darwin/source/`, `linux/source/`)

`.zshrc` sources all `*.sh` files from `source/` (and the platform-specific source dir) in numeric order. Scripts are numbered to control load order:

- `10-15` — terminal/locale/Homebrew init (must run first, no deps)
- `40-42` — PATH construction and terminal integrations (iTerm2, Ghostty)
- `45-55` — environment setup: editors, Go, Node (NVM lazy-loaded), AWS, GCloud, SSH agent, history, prompt
- `55` — keybindings
- `60` — zsh completion init (runs after PATH is set)
- `90` — PATH deduplication (runs last in setup)
- `99` — session messages (tmux indicators)

Add a new shell feature by creating a numbered `.sh` file in `source/`. Use lazy loading for slow-initializing tools (see `50_nvm.sh` for the pattern).

### Third-Party Submodules (`third_party/`)

- `dircolors-solarized` — solarized colors for `ls`/`grep` output
- `third_party/git/` — git-prompt script used by `50_prompt.sh`

Initialize submodules with `git submodule update --init` after cloning.

### Local Overrides (not in repo)

- `~/.zsh.local` — sourced at end of `.zshrc` for machine-specific config
- `~/.secrets/` — directory of files sourced by `50_secrets.sh` for credentials
- `~/.gitconfig.local` — not referenced directly, but `.gitconfig` uses `.gitconfig.platform` for per-OS credential helpers

### Docker

The `Makefile` builds/pushes a container image (`gcr.io/jbeda-prod/dotfiles`) that installs these dotfiles into an Ubuntu base. Targets: `make build`, `make push`, `make run`, `make kube-run`.
