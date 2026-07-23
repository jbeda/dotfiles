[[ -o interactive ]] || return

# cplan -- one command to (re)connect to claudes-plan and land in the `main`
# tmux session, replacing "ssh in, then type ta".
#
# It runs an INTERACTIVE login shell on the box (`zsh -ic`) before attaching, on
# purpose: linux/source/50_ssh_agent.sh only re-points the stable SSH_AUTH_SOCK
# symlink from an interactive login, and that repoint is what keeps long-lived
# tmux panes tracking this fresh connection's forwarded agent. A bare
# `ssh box -t tmux attach` skips it, which is exactly what leaves box-side git
# unable to auth after a reconnect. Detach (C-Spc d) or end the session to drop
# back to the Mac.
#
# Override the ssh host by exporting CPLAN_HOST in ~/.zsh.local. Use whatever
# name resolves on EVERY network you roam to -- your Tailscale MagicDNS name,
# not a home-only DNS name -- or reconnects will fail away from home.
# ServerAlive* makes a dropped network kill the ssh within ~30s (instead of
# hanging until TCP gives up), which is what lets the term-sane cleanup below
# run automatically after a disconnect. ConnectTimeout keeps reconnect
# attempts from hanging while the laptop's network is still settling.
cplan() {
  local host="${CPLAN_HOST:-claudes-plan}" rc
  term-sane  # clear any junk modes left by a previous dropped connection
  ssh -t \
    -o ServerAliveInterval=15 -o ServerAliveCountMax=2 -o ConnectTimeout=10 \
    "$host" 'exec zsh -ic "tmux new -A -s main"'
  rc=$?
  term-sane  # the remote tmux never got to undo its modes; do it locally
  return $rc
}
