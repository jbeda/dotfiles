if [[ ! "$SSH_TTY" ]] && which subl >/dev/null 2>&1; then
  export EDITOR='subl -w'
  export LESSEDIT='subl %f'
else
  export EDITOR=$(type emacs nano pico 2>/dev/null | sed 's/ .*$//;q')
fi

export VISUAL="$EDITOR"
