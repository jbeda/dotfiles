if [[ ! "$SSH_TTY" ]] && which atom >/dev/null 2>&1; then
  export EDITOR='atom --wait'
  export LESSEDIT='atom %f'
else
  export EDITOR=$(type emacs nano pico 2>/dev/null | sed 's/ .*$//;q')
fi

export VISUAL="$EDITOR"
