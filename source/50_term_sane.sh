[[ -o interactive ]] || return

# term-sane -- undo terminal modes a dead remote session can leave enabled.
# When ssh drops mid-tmux, the remote never sends its cleanup sequences, so
# the local terminal keeps mouse tracking on (mouse movement prints escape
# junk), plus possibly bracketed paste, focus reporting, and the alt screen.
# Unlike `reset`, this only flips modes off: no screen clear, no delay.
# Callable by hand whenever a terminal is acting haunted.
term-sane() {
  #        mouse tracking off  encodings off       focus off  paste off
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1005l\e[?1006l\e[?1015l\e[?1004l\e[?2004l'
  #        kitty kbd pop  leave alt screen  show cursor
  printf '\e[<u\e[?1049l\e[?25h'
  stty sane 2>/dev/null
}
