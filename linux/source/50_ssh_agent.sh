# If not running interactively, don't do anything
[[ -o interactive ]] || return

# Maintain a single shared ssh-agent on a fixed socket path. The fixed path
# makes startup race-free: binding the socket is atomic (the second agent to
# try simply fails), and flock serializes the check-and-start so concurrent
# login shells don't each launch an agent.
#
# macOS doesn't need any of this: launchd provides an agent, and
# AddKeysToAgent/UseKeychain in ~/.ssh/config handle key loading.

export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-$HOME/.ssh}/ssh-agent.socket"

# ssh-add exits 2 when no agent is reachable; 1 just means no keys loaded.
ssh-add -l &> /dev/null
if [[ $? -eq 2 ]]; then
    mkdir -p "$(dirname "$SSH_AUTH_SOCK")"
    if flock "${SSH_AUTH_SOCK}.lock" sh -c '
        ssh-add -l > /dev/null 2>&1
        [ $? -eq 2 ] || exit 1   # another shell won the race; nothing to do
        rm -f "$SSH_AUTH_SOCK"   # socket is stale if no agent answered
        ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null
    '; then
        # Only the shell that started the agent loads the key, so a burst of
        # login shells produces at most one passphrase prompt.
        ssh-add
    fi
fi
