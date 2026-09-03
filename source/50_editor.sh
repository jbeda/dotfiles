if [[ ! "$SSH_TTY" ]] && which code >/dev/null 2>&1; then
  export EDITOR='code --wait'
  export LESSEDIT='code %f'
else
  for _ed in emacs nano pico vi; do
    if command -v "$_ed" >/dev/null 2>&1; then
      export EDITOR="$_ed"
      break
    fi
  done
  unset _ed
fi

export VISUAL="$EDITOR"
