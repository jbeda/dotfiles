# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Set up editor
export VISUAL="emacs"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# You can tell tab completion to ignore certain file extensions.
FIGNORE=.o:~:.pyc:.class

# Tell me whether I'm running screen
if [ -n "$TMUX" ]; then
    echo You are currently inside tmux pane $TMUX_PANE
    # When I'm in screen, I don't want Ctrl-d to log me out.
    IGNOREEOF=255
fi
#if screen -list | grep -q -E 'There is a screen|There are screens'; then
#    screen -list
#fi

# Prevent less from clearing the screen while still showing colors.
export LESS=-XR

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# SSH auto-completion based on entries in known_hosts.
if [[ -e ~/.ssh/known_hosts ]]; then
  complete -o default -W "$(cat ~/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp sftp
fi

# ==============================
# History

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# ==============================
# Prompt

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-*color) color_prompt=yes;;
    screen-*color) color_prompt=yes;;
esac

ps_user="$(whoami)"
ps_pane=""
if [ -n "$TMUX" ]; then
    ps_pane="\[\033[32m\](${TMUX_PANE}) "
fi

if [ "$color_prompt" = yes ]; then
    # For dark colored backgrounds: [user@host:dir] $
    PS1="\[\e[0;36m\][${ps_user}\[\e[0;36m\]@\h\[\e[0;36m\]:\[\e[37m\]\w\[\e[0;36m\]] ${ps_pane}\[\e[33m\]\$ \[\e[0m\]"    
    # Add date/time
    PS1="\[\033[0;90m\] \d \[\033[1m\]\t\[\033[0m\]\r\n$PS1"
    # Display a smiley for success/failure [from galina@google.com]
    PS1="\`if [ \$? = 0 ]; then echo \[\e[32\;1\;40m\]:\\\); else echo \[\e[31\;1\;40m\]:\\\(; fi\`\[\e[0m\]$PS1"
else
    PS1="[${ps_user}@\h:\w] \$ "
fi
unset color_prompt force_color_prompt

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
