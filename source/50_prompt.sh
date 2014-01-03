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
