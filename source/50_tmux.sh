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
