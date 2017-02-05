if [[ ! "$SSH_TTY" ]] && which code >/dev/null 2>&1; then
  export EDITOR='code --wait'
  export LESSEDIT='code %f'
else
  export EDITOR=$(type emacs nano pico 2>/dev/null | sed 's/ .*$//;q')
fi

export VISUAL="$EDITOR"
