[[ -o interactive ]] || return

# Reverse-SSH bridge to the Mac (Linux/remote side).
#
# A single launchd listener on the SSH *client* (your Mac) reads one
# "verb<TAB>args" line off a reverse-forwarded port and dispatches it:
#   open <url>              -> open the URL in the Mac browser  (linux/bin/browse)
#   code <host> <path>      -> code --remote ssh-remote+<host> <path> on the Mac
#                              i.e. VS Code on the Mac, attached to a dir here
#   clip-image <host> <dst> -> scp the Mac's clipboard image to <host>:<dst>
#                              here (linux/bin/paste-image; C-Spc i in tmux)
# Mac side + ssh config: darwin/mac-bridge/.
export MAC_BRIDGE_PORT=17603

# Which ssh Host alias the Mac uses to reach THIS box -- passed to `code
# --remote ssh-remote+<host>` so VS Code knows how to connect back. Defaults to
# the short hostname; override in ~/.zsh.local if that isn't your ssh alias.
export MAC_SSH_HOST="${MAC_SSH_HOST:-$(hostname -s)}"

# `browse`/`code-mac` still exist off-SSH; we only remap open/xdg-open/$BROWSER
# to `browse` while we're the far end of an SSH session, so local tools behave
# normally when this box is used directly.
if [[ -n "$SSH_CONNECTION" ]]; then
  export BROWSER=browse          # honored by xdg-open, python -m webbrowser, gh, ...
  alias open='browse'            # muscle-memory parity with macOS
  alias xdg-open='browse'
fi
