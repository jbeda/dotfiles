# Include the cool git prompt integration stuff
source "${DOTFILES_ROOT}/third_party/git/git-prompt.sh"
GIT_PS1_SHOWDIRTYSTATE=y
GIT_PS1_SHOWUNTRACKEDFILES=y
GIT_PS1_SHOWCOLORHINTS=y
GIT_PS1_DESCRIBE_STYLE=describe

ps_user="$(whoami)"
ps_pane=""

if [[ -n "$TERM" && $(tput colors) -ge 8 ]]; then
  tput sgr0
  if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
    BASE03="\[$(tput setaf 234)\]"
    BASE02="\[$(tput setaf 235)\]"
    BASE01="\[$(tput setaf 240)\]"
    BASE00="\[$(tput setaf 241)\]"
    BASE0="\[$(tput setaf 244)\]"
    BASE1="\[$(tput setaf 245)\]"
    BASE2="\[$(tput setaf 254)\]"
    BASE3="\[$(tput setaf 230)\]"
    YELLOW="\[$(tput setaf 136)\]"
    ORANGE="\[$(tput setaf 166)\]"
    BARE_RED=$(tput setaf 160)
    RED="\[$(tput setaf 160)\]"
    MAGENTA="\[$(tput setaf 125)\]"
    VIOLET="\[$(tput setaf 61)\]"
    BLUE="\[$(tput setaf 33)\]"
    CYAN="\[$(tput setaf 37)\]"
    BARE_GREEN=$(tput setaf 64)
    GREEN="\[$(tput setaf 64)\]"
  else
    BASE03="\[$(tput setaf 8)\]"
    BASE02="\[$(tput setaf 0)\]"
    BASE01="\[$(tput setaf 10)\]"
    BASE00="\[$(tput setaf 11)\]"
    BASE0="\[$(tput setaf 12)\]"
    BASE1="\[$(tput setaf 14)\]"
    BASE2="\[$(tput setaf 7)\]"
    BASE3="\[$(tput setaf 15)\]"
    YELLOW="\[$(tput setaf 3)\]"
    ORANGE="\[$(tput setaf 9)\]"
    BARE_RED=$(tput setaf 1)
    RED="\[$(tput setaf 1)\]"
    MAGENTA="\[$(tput setaf 5)\]"
    VIOLET="\[$(tput setaf 13)\]"
    BLUE="\[$(tput setaf 4)\]"
    CYAN="\[$(tput setaf 6)\]"
    BARE_GREEN=$(tput setaf 2)
    GREEN="\[$(tput setaf 2)\]"
  fi
  BOLD="\[$(tput bold)\]"
  RESET="\[$(tput sgr0)\]"

  if [ -n "$TMUX" ]; then
    ps_pane=" ${GREEN}(${TMUX_PANE})"
  fi

  if [[ -z "$DISABLE_GIT_PROMPT" ]]; then
    ps_git="${MAGENTA}\$(__git_ps1)"
  fi

  ps_cloud="🏠"
  if grep Google /sys/class/dmi/id/bios_vendor 2> /dev/null ; then
    ps_cloud="☁️"
  fi

  if [ "$USER" = "root" ]; then
    PS1="${RED}🐙 "
  else
    PS1="${ORANGE}💰 "
  fi

  ps_extra=""

  # For dark colored backgrounds: [user@host:dir] $
  PS1="${BASE0}\w${CYAN}\${ps_extra}${ps_pane}${ps_git}${PS1} ${BASE0}"
  # Add date/time
  PS1="${BASE01}\d ${VIOLET}${ps_user}@\h $ps_cloud\r\n${PS1}"
  # Display a smiley for success/failure [from galina@google.com]
  PS1="\`if [ \$? = 0 ]; then echo 😄; else echo 😡; fi\`  ${PS1}"
else
  PS1="[${ps_user}@\h:\w] \$ "
fi
