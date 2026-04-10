[[ -o interactive ]] || return

# Include the cool git prompt integration stuff
source "${DOTFILES_ROOT}/third_party/git/git-prompt.sh"
GIT_PS1_SHOWDIRTYSTATE=y
GIT_PS1_SHOWUNTRACKEDFILES=y
GIT_PS1_DESCRIBE_STYLE=describe

setopt PROMPT_SUBST

ps_user="$(whoami)"
ps_extra=""

if [[ -n "$TERM" && $(tput colors 2>/dev/null) -ge 8 ]]; then
  tput sgr0
  if [[ $(tput colors 2>/dev/null) -ge 256 ]]; then
    BASE03="%{$(tput setaf 234)%}"
    BASE02="%{$(tput setaf 235)%}"
    BASE01="%{$(tput setaf 240)%}"
    BASE00="%{$(tput setaf 241)%}"
    BASE0="%{$(tput setaf 244)%}"
    BASE1="%{$(tput setaf 245)%}"
    BASE2="%{$(tput setaf 254)%}"
    BASE3="%{$(tput setaf 230)%}"
    YELLOW="%{$(tput setaf 136)%}"
    ORANGE="%{$(tput setaf 166)%}"
    RED="%{$(tput setaf 160)%}"
    MAGENTA="%{$(tput setaf 125)%}"
    VIOLET="%{$(tput setaf 61)%}"
    BLUE="%{$(tput setaf 33)%}"
    CYAN="%{$(tput setaf 37)%}"
    GREEN="%{$(tput setaf 64)%}"
  else
    BASE03="%{$(tput setaf 8)%}"
    BASE02="%{$(tput setaf 0)%}"
    BASE01="%{$(tput setaf 10)%}"
    BASE00="%{$(tput setaf 11)%}"
    BASE0="%{$(tput setaf 12)%}"
    BASE1="%{$(tput setaf 14)%}"
    BASE2="%{$(tput setaf 7)%}"
    BASE3="%{$(tput setaf 15)%}"
    YELLOW="%{$(tput setaf 3)%}"
    ORANGE="%{$(tput setaf 9)%}"
    RED="%{$(tput setaf 1)%}"
    MAGENTA="%{$(tput setaf 5)%}"
    VIOLET="%{$(tput setaf 13)%}"
    BLUE="%{$(tput setaf 4)%}"
    CYAN="%{$(tput setaf 6)%}"
    GREEN="%{$(tput setaf 2)%}"
  fi
  RESET="%{$(tput sgr0)%}"

  ps_cloud="🏠"
  if grep -q Google /sys/class/dmi/id/bios_vendor 2>/dev/null; then
    ps_cloud="☁️"
  fi

  # If PID 1 isn't `init` or `systemd` there is a good chance we are
  # containerized.
  if [[ -d /proc ]] && grep -qvE '(init|systemd)' /proc/1/cmdline 2>/dev/null; then
    ps_cloud="📦"
  fi

  if [[ "$USER" = "root" ]]; then
    ps_symbol="${RED}🐙 "
  else
    ps_symbol="${ORANGE}💰 "
  fi

  _prompt_precmd() {
    _ps_exit=$?

    # Truncate directory path dynamically based on terminal width
    local dir="${PWD/#$HOME/~}"
    local max_len=$(( COLUMNS * 2 / 5 ))
    if (( max_len > 10 && ${#dir} > max_len )); then
      _ps_dir="...${dir: -$(( max_len - 3 ))}"
    else
      _ps_dir="$dir"
    fi

    # Git status (1-arg mode: returns formatted string)
    if [[ -z "$DISABLE_GIT_PROMPT" ]]; then
      local git_str
      git_str="$(__git_ps1 '%s')"
      if [[ -n "$git_str" ]]; then
        _ps_git=" ${MAGENTA}(${git_str})${RESET}"
      else
        _ps_git=""
      fi
    else
      _ps_git=""
    fi

    # Extra prompt content (set ps_extra in .zsh.local to inject something here)
    if [[ -n "$ps_extra" ]]; then
      _ps_extra="${CYAN}${ps_extra}${RESET}"
    else
      _ps_extra=""
    fi

    # Tmux pane indicator
    if [[ -n "$TMUX" ]]; then
      _ps_pane=" ${GREEN}(${TMUX_PANE})${RESET}"
    else
      _ps_pane=""
    fi
  }
  # Prepend so we capture $? before any other precmd functions run
  precmd_functions=(_prompt_precmd "${precmd_functions[@]}")

  # PROMPT construction:
  #   Double-quoted sections expand NOW (baking in color codes, username, cloud indicator).
  #   Single-quoted sections expand at RENDER TIME via PROMPT_SUBST (dir, git, exit code, date).
  #   %m is a zsh prompt expansion for hostname (always render-time).
  #
  # Line 1: date  user@host  cloud
  # Line 2: smiley  dir  [extra]  [pane]  [git]  symbol
  PROMPT="${BASE01}"'$(date +"%a %b %d") '"${VIOLET}${ps_user}@%m ${ps_cloud}"$'\n''$([ $_ps_exit = 0 ] && echo 😄 || echo 😡) '"${BASE0}"'${_ps_dir}${_ps_extra}${_ps_pane}${_ps_git}'"${ps_symbol}${BASE0}"
else
  PROMPT="[${ps_user}@%m:%~] %# "
fi
