[[ -o interactive ]] || return

# enable color support of ls and also add handy aliases

# brew installs gnu coreutils with a 'g' prefix
if command -v gdircolors >/dev/null 2>&1; then
  alias dircolors='gdircolors'
fi

if command -v dircolors >/dev/null 2>&1; then
  eval $(dircolors "${DOTFILES_ROOT}/third_party/dircolors-solarized/dircolors.256dark")

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
