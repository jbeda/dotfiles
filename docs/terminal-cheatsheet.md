# Terminal setup cheat sheet

The whole environment at a glance: the prompt and its symbols, how the shell
behaves, the aliases and helper commands, and where each lives. `⭐` marks a
custom convenience from this repo (vs. a stock default). tmux has its own
detailed sheet — see [tmux-cheatsheet.md](tmux-cheatsheet.md).

Everything here is wired up by the numbered `*.sh` files under `source/` (and
`linux/source/`, `darwin/source/` for platform-specific bits). Reload after an
edit with `src` ⭐ (see [Helpers](#helpers--functions)).

## Reading the prompt (Starship)

The prompt is [Starship](https://starship.rs), configured in
`config/starship.toml` and initialized by `source/50_prompt.sh`. It's three
lines:

```
Wed Jul 22 11:52  jbeda@claudes-plan            3m12s
~/src/dotfiles  (master ✘!?)
❯
```

| Part | What it tells you |
| --- | --- |
| `Wed Jul 22 11:52` | Timestamp of **when this prompt was drawn** — scan scrollback to see roughly when things ran |
| `jbeda@claudes-plan` | `user@host` — always shown. The hostname's color is a **stable hash of its name** ⭐, so each machine you land on gets its own color — a glance tells you where you are |
| `3m12s` | How long the **previous command** took. Only appears when it ran longer than **2s** |
| `~/src/dotfiles` | Current directory (full path, home shortened to `~`, truncated to the last 4 segments if deep) |
| `(master ✘!?)` | Git branch + status — see the symbol legend below. A clean repo shows just `(master)` |
| `❯` | Where you type. **Green** = last command succeeded, **red** = it exited non-zero ⭐ |

Running as **root** prepends a loud red ` ROOT ` block to line 1 and turns the
`user@host` red ⭐ — hard to miss, on purpose.

### Git status symbols — the "lingua franca"

These appear inside `(branch …)`. They're Starship's defaults (shared with
many prompts, so worth memorizing). Each shows only when that kind of change is
present; several can stack, e.g. `✘!?`:

| Symbol | Meaning | Rough git equivalent |
| --- | --- | --- |
| `!` | **modified** — tracked file edited but not staged | `git status`: "not staged for commit" |
| `+` | **staged** — changes added with `git add` | "to be committed" |
| `?` | **untracked** — new file git isn't tracking yet | "untracked files" |
| `✘` | **deleted** — a tracked file was removed | `D` in `git status --short` |
| `»` | **renamed** — a tracked file was renamed | `R` |
| `$` | **stashed** — you have entries in `git stash` | — |
| `=` | **conflicted** — merge/rebase conflict to resolve | "unmerged paths" |
| `⇡N` | **ahead** — N local commits not yet pushed | ahead of upstream |
| `⇣N` | **behind** — N upstream commits not yet pulled | behind upstream |
| `⇕` | **diverged** — both ahead *and* behind | needs rebase |

So `(master ✘!?)` = on `master`, with a deletion, an unstaged edit, and an
untracked file. Nothing after the branch = clean tree. All symbols are
remappable in `config/starship.toml` under `[git_status]` if you ever want
words instead.

## Shell behavior (zsh)

Handy defaults set in `source/50_misc.sh` and `source/50_history.sh`:

| Behavior | What it means |
| --- | --- |
| **AUTO_CD** ⭐ | Type a directory name (no `cd`) to change into it |
| **Shared history** ⭐ | All open shells share one history in real time — a command run in one pane is instantly recallable in another |
| **Prefix history search** ⭐ | Type the start of a command, press **↑** to cycle only matching past commands (e.g. `git`↑ walks your git history) |
| **Ignore-space** | A command typed with a leading space is kept out of history |
| **Case-insensitive globbing** | `*.MD` matches `*.md` |
| `#` comments | Allowed at an interactive prompt |
| No bell | Terminal bell silenced |

History holds 50k lines in-session, 10k on disk, with timestamps.

### Line-editing keys

Emacs-style editing (`bindkey -e`), configured in `source/55_keybindings.sh`:

| Keys | Action |
| --- | --- |
| **↑ / ↓** | Prefix history search (above) |
| **Home / End** | Jump to start / end of line |
| **Delete** | Delete forward |
| **Ctrl-A / Ctrl-E** | Start / end of line (emacs) |
| **Ctrl-R** | Reverse-search history |
| **Esc-Backspace** | Delete previous word; stops at `/` so you can chip path segments ⭐ |

## Aliases

Shell aliases (platform-guarded where noted):

| Alias | Expands to | Where |
| --- | --- | --- |
| `ls` | colorized `ls` (solarized) | `50_misc.sh` |
| `grep` / `fgrep` / `egrep` | colorized | `50_misc.sh` |
| `tl` ⭐ | `tmux ls` | `50_tmux.sh` |
| `td` ⭐ | `tmux detach` | `50_tmux.sh` |
| `gce` | `gcloud compute` | `50_cloud_sdk.sh` (if gcloud present) |
| `open` / `xdg-open` ⭐ | `browse` (open on the Mac) | `linux/source/50_mac_bridge.sh` (Linux + bridge) |
| `code` | `code --disable-gpu` | `linux/source/50_code.sh` (Linux) |

### Git aliases

From `link/.gitconfig` — use as `git <alias>`:

| Alias | Runs | Notes |
| --- | --- | --- |
| `st` | `status` | |
| `co` / `ci` / `br` | `checkout` / `commit` / `branch` | |
| `df` | `diff` | |
| `lg` | `log -p` | log with patches |
| `g` | `grep -I` | skip binary files |
| `amend` | `commit -n --amend --no-edit` | fold staged changes into last commit |
| `fa` | `fetch --all --prune` | |
| `furb` ⭐ | fetch `upstream` + `rebase upstream/main` | the rebase-not-merge sync flow |
| `pr <N>` ⭐ | fetch upstream PR #N into `pr-N` and check it out | |
| `pp` | pull then push | |
| `superclean` | `clean -fdx` keeping editor/gcloud files | destructive — removes untracked |
| `delete-merged-into-upstream` ⭐ | delete local branches already merged upstream | |

## Helpers & functions

| Command | What it does | Where |
| --- | --- | --- |
| `src [module]` ⭐ | Re-source your whole zsh config, or one `source/<module>.sh`. Fastest way to apply an edit without a new shell | `link/.zshrc` |
| `ta [name]` ⭐ | Attach to (or create) tmux session `name` (default `main`) | `50_tmux.sh` |
| `cw [profile] [dir]` ⭐ | New tmux window: two panes, Claude Code left + shell right. See [tmux sheet](tmux-cheatsheet.md#two-pane-claude-workspace-cw-) | `50_tmux.sh` |
| `cplan` ⭐ | (Mac) SSH into `claudes-plan` and attach its `main` session | `darwin/source/50_cplan.sh` |
| `browse <url\|file>` ⭐ | (Linux) open a URL/file on the Mac over the bridge; also `$BROWSER` for `gh`, `python -m webbrowser`, etc. | `linux/bin/browse` |
| `paste-image` ⭐ | (Linux) pull the Mac clipboard image over the bridge, print its local path. Also bound to `C-Spc i` in tmux | `linux/bin/paste-image` |
| `mise …` | Runtime versions (Node today). Pins live in `config/mise/config.toml` — edit there, not `mise use -g`. `./install` bootstraps the binary + runtimes | `50_mise.sh` |
| `wt …` | Worktrunk — git worktree manager (external tool, shell hooks loaded if installed) | `50_wt.sh` |
| `titlebar <text>` | Set the terminal title bar | `50_misc.sh` |

## Editor

`$EDITOR` / `$VISUAL` resolve in `source/50_editor.sh`:

- **Local** (has `code`, not over SSH): `code --wait`
- **Over SSH / headless**: first of `emacs`, `nano`, `pico` found

## tmux

Prefix is **`Ctrl-Space`** ⭐. The full window/pane/copy-mode reference lives in
its own sheet: **[tmux-cheatsheet.md](tmux-cheatsheet.md)**. Quick hits:

| Action | Keys / command |
| --- | --- |
| Attach/create `main` | `ta` ⭐ |
| Detach | `C-Spc d` (or `td` ⭐ from a nested shell) |
| New window / split | `C-Spc c` / `C-Spc |` `C-Spc -` ⭐ |
| Paste Mac clipboard image → path | `C-Spc i` ⭐ |

## Learn more

- `man zshoptions` / `man zshbuiltins` — the zsh reference
- [Starship config docs](https://starship.rs/config/) — every prompt module and symbol
- `git help <alias-target>` — e.g. `git help rebase` behind `furb`
- [tmux-cheatsheet.md](tmux-cheatsheet.md) — the tmux companion to this sheet
