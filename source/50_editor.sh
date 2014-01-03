if [[ ! "$SSH_TTY" && "$OSTYPE" =~ ^darwin ]]; then
  export EDITOR='subl -w'
  export LESSEDIT='subl %f'
else
  export EDITOR=$(type emacs nano pico 2>/dev/null | sed 's/ .*$//;q')
fi

export VISUAL="$EDITOR"
