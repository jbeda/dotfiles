# Usage: iterm2_set_user_var key value
function iterm2_set_badge() {
  iterm2_begin_osc
  printf "1337;SetBadgeFormat=%s" $(printf "%s" "$1" | base64 | tr -d '\n')
  iterm2_end_osc
}