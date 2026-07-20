# tmux cheat sheet

Prefix is **`Ctrl-b`** (press and release, then the next key). Written below as
`C-b`. Your `~/.tmux.conf` in this repo adds a few conveniences noted with ⭐.

## The core workflow: attach / detach

This is the whole reason to use tmux — a session keeps running on the machine
after you disconnect.

| Action | Command (from the shell) |
| --- | --- |
| Start/attach a session named `main` | `ta` ⭐ (alias) or `tmux new -A -s main` |
| Start a named session | `tmux new -s agent` |
| Detach (leave it running) | `C-b d` |
| List sessions | `tl` ⭐ or `tmux ls` |
| Attach to a session | `tmux attach -t agent` |
| Kill a session | `tmux kill-session -t agent` |

**Reconnecting over SSH:** just `ssh` in normally and run `ta` (or
`tmux attach`). Doing it from an interactive login re-points your SSH-agent
symlink, so existing panes keep working with your forwarded keys. Avoid
`ssh host -t tmux attach` — it's non-interactive and skips that refresh.

## Windows (like tabs)

| Action | Keys |
| --- | --- |
| New window | `C-b c` |
| Next / previous window | `C-b n` / `C-b p` |
| Jump to window N | `C-b 1` … `C-b 9` (windows start at 1 ⭐) |
| Rename current window | `C-b ,` |
| Window picker (visual) | `C-b w` |
| Close window | `C-b &` (confirms) |

## Panes (splits)

| Action | Keys |
| --- | --- |
| Split left/right | `C-b %` or `C-b |` ⭐ (keeps current dir) |
| Split top/bottom | `C-b "` or `C-b -` ⭐ (keeps current dir) |
| Move between panes | `C-b ↑ ↓ ← →` |
| Cycle panes | `C-b o` |
| Zoom pane in/out (fullscreen toggle) | `C-b z` |
| Resize pane | `C-b` then hold and repeat `C-↑ ↓ ← →` |
| Convert pane to its own window | `C-b !` |
| Close pane | `C-b x` (confirms) or type `exit` |

## Copy / scroll mode

| Action | Keys |
| --- | --- |
| Enter copy/scroll mode | `C-b [` |
| Scroll | arrows / PgUp / PgDn, or **mouse wheel** (mouse is on) |
| Start selection (emacs keys) | `C-Space`, move, `M-w` to copy |
| Search backward | `C-r` |
| Quit copy mode | `q` |

Copied text goes to your **Mac clipboard** via OSC 52 (thanks to
`set-clipboard on` + Ghostty). With the mouse you can also just drag to select.

> **Mouse-mode gotcha:** when tmux mouse mode is on, dragging selects into
> tmux's buffer, not the OS clipboard. To make a *native* Ghostty selection
> (e.g. to copy with ⌘C), **hold Shift while dragging**.

## Session & misc

| Action | Keys |
| --- | --- |
| Reload config | `C-b r` ⭐ |
| Command prompt (type any tmux command) | `C-b :` |
| Rename session | `C-b $` |
| Session picker (visual) | `C-b s` |
| List all key bindings | `C-b ?` |
| Show a big clock | `C-b t` |

## Persistence across reboots (resurrect + continuum) ⭐

Detach/reattach needs no help — the session and its processes keep running.
These plugins add recovery across a **reboot or tmux-server restart**.

| Action | Keys |
| --- | --- |
| Save layout now | `C-b C-s` |
| Restore last saved layout | `C-b C-r` |

Continuum autosaves every 15 min and **auto-restores on tmux startup**, so
after a reboot your windows/panes/cwd come back on their own. Caveat: a reboot
kills running processes (agents too) — the plugins restore the *layout and
shells*, not a live process's memory. Relaunch the agent in the restored pane.

## Sending a literal `C-b` to the shell

Because the prefix is `C-b` (which is also emacs "back one char"), press
**`C-b C-b`** to send a single `Ctrl-b` through to the program underneath.

## Handy from-the-shell commands

```sh
tmux ls                      # list sessions
tmux new -s NAME             # create a session
tmux attach -t NAME          # attach
tmux kill-session -t NAME    # kill one session
tmux kill-server             # kill everything
tmux source-file ~/.tmux.conf   # reload config outside tmux
```

## Learn more

- `man tmux` — the authoritative reference (long but searchable).
- `C-b ?` inside tmux — live list of every current binding.
- Official wiki: https://github.com/tmux/tmux/wiki
