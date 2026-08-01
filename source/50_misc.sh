[[ -o interactive ]] || return

# enable color support of ls and also add handy aliases

# brew installs gnu coreutils with a 'g' prefix
if command -v gdircolors >/dev/null 2>&1; then
  alias dircolors='gdircolors'
fi

# LS_COLORS, themed to match everything else (Ghostty, tmux, VS Code all on
# Catppuccin Mocha). vivid generates it from a YAML filetype database, so the
# palette is one word to change rather than a wall of hex.
#   macOS:  brew install vivid
#   Debian: sudo apt install vivid
# Costs a process spawn per interactive shell; vivid is a few ms, and this file
# is already interactive-only.
#
# Errors are deliberately NOT swallowed. A vivid too old to know the theme would
# otherwise export an empty LS_COLORS and silently fall back to unthemed output
# -- the kind of quiet degradation that's much more expensive to debug than a
# visible error at shell start.
if command -v vivid >/dev/null 2>&1; then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"
fi

# Without vivid, LS_COLORS stays unset and GNU ls falls back to its own built-in
# defaults -- still colored, just not themed.
if command -v dircolors >/dev/null 2>&1; then
  alias ls='ls --color=auto'
  command -v gls >/dev/null 2>&1 && alias ls='gls --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
elif [ "$(uname)" = "Darwin" ]; then
  alias ls='ls -G'
fi

# Case-insensitive globbing (used in pathname expansion)
setopt NOCASEGLOB

# Type a directory name to cd into it
setopt AUTO_CD

# Allow # comments in an interactive shell
setopt INTERACTIVE_COMMENTS

# Silence the terminal bell
setopt NO_BEEP

# You can tell tab completion to ignore certain file extensions.
FIGNORE=.o:~:.pyc:.class

# make less more friendly for non-text input files, see lesspipe(1)
command -v lesspipe >/dev/null 2>&1 && eval "$(lesspipe)"
command -v lesspipe.sh >/dev/null 2>&1 && eval "$(lesspipe.sh)"

# Prevent less from clearing the screen while still showing colors.
export LESS=-XR

# Set the terminal's title bar.
function titlebar() {
  echo -ne "\ek$1\e\\"
}
