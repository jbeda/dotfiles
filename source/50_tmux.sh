[[ -o interactive ]] || return

# tmux attach/detach helpers for long-running sessions on this machine.
#
# Attaching from a fresh interactive login is what re-points the stable
# SSH_AUTH_SOCK symlink (see linux/source/50_ssh_agent.sh), so prefer SSHing
# in and running `ta` over `ssh host -t tmux attach` -- the latter is
# non-interactive and won't refresh the agent link.

alias tl='tmux ls'                        # list sessions
alias td='tmux detach'                    # detach current client

# Attach to a session (default name "main"), creating it if it doesn't exist.
# Usage: ta            -> attach/create "main"
#        ta agent      -> attach/create "agent"
ta() {
  local name="${1:-main}"
  tmux new-session -A -s "$name"
}

# cw [profile] [dir] -- open a NEW tmux window (leaving the current pane
# untouched) split into two side-by-side panes rooted in <dir>:
#   left  -> Claude Code, launched via `cswap run [profile]`
#   right -> a plain shell in the same dir
# <profile> is a cswap account num/alias; omit it to use the directory's mapped
# account. <dir> defaults to the current directory. The first argument is taken
# as <dir> if it looks like a path (contains "/", or is "~...", "." or "..").
# Focus lands on the Claude pane. Requires being inside tmux.
# Examples:
#   cw                  # dir's mapped account, here
#   cw 2                # cswap account 2, here
#   cw 2 ~/src/myproj   # cswap account 2, in myproj
#   cw ~/src/myproj     # dir's mapped account, in myproj
cw() {
  if [[ -z "$TMUX" ]]; then
    echo "cw: not inside tmux" >&2
    return 1
  fi

  local profile="" dir=""
  if [[ "$1" == */* || "$1" == "~"* || "$1" == "." || "$1" == ".." ]]; then
    dir="$1"
  else
    profile="$1"
    dir="$2"
  fi
  dir="${dir:-$PWD}"
  dir="${dir:a}"          # normalize to an absolute path (symlinks preserved)

  if [[ ! -d "$dir" ]]; then
    echo "cw: no such directory: $dir" >&2
    return 1
  fi

  local run="cswap run"
  [[ -n "$profile" ]] && run+=" $profile"

  tmux new-window -c "$dir" -n "${dir:t}" \; \
    split-window -h -c "$dir" \; \
    select-pane -L \; \
    send-keys "$run" Enter
}
