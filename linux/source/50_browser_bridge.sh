[[ -o interactive ]] || return

# Reverse-SSH browser bridge (Linux/remote side).
#
# Route URL-opening to the browser on the SSH *client* (your Mac): `browse`
# (in ~/.local/bin) sends the URL over a reverse-forwarded port to a listener
# on the Mac that runs `open`. Setup: darwin/browser-bridge/.
#
# `browse` still exists off-SSH; we only remap open/xdg-open/$BROWSER to it
# while we're the far end of an SSH session, so local tools behave normally
# when this box is used directly.
export BROWSER_BRIDGE_PORT=17603

if [[ -n "$SSH_CONNECTION" ]]; then
  export BROWSER=browse          # honored by xdg-open, python -m webbrowser, gh, ...
  alias open='browse'            # muscle-memory parity with macOS
  alias xdg-open='browse'
fi
