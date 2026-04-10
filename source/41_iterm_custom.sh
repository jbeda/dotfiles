[[ -o interactive ]] || return

# Usage: iterm2_set_badge <text>
# Requires iTerm2 shell integration to be installed.
function iterm2_set_badge() {
  iterm2_begin_osc
  printf "1337;SetBadgeFormat=%s" $(printf "%s" "$1" | base64 | tr -d '\n')
  iterm2_end_osc
}
