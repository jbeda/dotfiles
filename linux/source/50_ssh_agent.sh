# If not running interactively, don't do anything
[[ -o interactive ]] || return

# Maintain a stable SSH_AUTH_SOCK path so tmux panes and reattached sessions
# always reference the same socket. That path is a symlink we repoint at
# whichever live agent this login should use:
#
#   - an agent forwarded from the client (`ssh -A`), preferred when present, or
#   - a single shared local agent on a fixed path, started on demand.
#
# Forwarded sockets live at a per-connection /tmp/ssh-*/agent.* path that dies
# when the connection drops, so on each login we relink the stable path at the
# freshest forwarded socket; tmux panes following the symlink then track it
# across reconnects. SSH_AUTH_SOCK holds a single path, so this is prefer-one,
# not merge-both — you can't chain two agents.
#
# macOS doesn't need any of this: launchd provides an agent, and
# AddKeysToAgent/UseKeychain in ~/.ssh/config handle key loading.

ssh_agent_link="${XDG_RUNTIME_DIR:-$HOME/.ssh}/ssh-agent.socket"
ssh_agent_local="${XDG_RUNTIME_DIR:-$HOME/.ssh}/ssh-agent.local.socket"
mkdir -p "$(dirname "$ssh_agent_link")"

# Prefer an agent handed to this session (e.g. forwarded via `ssh -A`). It's
# inherited when SSH_AUTH_SOCK points somewhere other than our stable symlink
# and answers. ssh-add -l exits 2 when no agent is reachable; 0/1 mean it is.
if [[ -n "$SSH_AUTH_SOCK" && "$SSH_AUTH_SOCK" != "$ssh_agent_link" ]]; then
    ssh-add -l &> /dev/null
    if [[ $? -ne 2 ]]; then
        ln -sfn "$SSH_AUTH_SOCK" "$ssh_agent_link"
        export SSH_AUTH_SOCK="$ssh_agent_link"
        return
    fi
fi

# No forwarded agent: fall back to the shared local agent via the stable path.
export SSH_AUTH_SOCK="$ssh_agent_link"

# ssh-add follows the symlink to whatever it currently targets; exit 2 means
# that target is dead or missing, so we (re)start the local agent. flock
# serializes the check-and-start so concurrent login shells don't each launch
# an agent or race on the relink.
ssh-add -l &> /dev/null
if [[ $? -eq 2 ]]; then
    if flock "${ssh_agent_link}.lock" sh -c '
        SSH_AUTH_SOCK="$2" ssh-add -l > /dev/null 2>&1
        [ $? -eq 2 ] || exit 1   # another shell won the race; nothing to do
        rm -f "$1"               # stale local socket if no agent answered
        ssh-agent -a "$1" > /dev/null
        ln -sfn "$1" "$2"        # point the stable path at the fresh agent
    ' _ "$ssh_agent_local" "$ssh_agent_link"; then
        # Only the shell that started the agent loads the key, so a burst of
        # login shells produces at most one passphrase prompt.
        ssh-add
    fi
fi
