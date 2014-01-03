# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if [ -n "$TMUX" ]; then
    echo You are currently inside tmux pane $TMUX_PANE
    # When I'm in screen, I don't want Ctrl-d to log me out.
    IGNOREEOF=255
fi
