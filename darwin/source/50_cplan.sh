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

# mcplan -- cplan over mosh, for high-latency or lossy links (airplane and
# hotel wifi, tethering). Same host and same landing spot, so the two are
# interchangeable; reach for this one when the link is bad.
#
# Two things mosh buys on a slow link. Local echo renders your keystrokes
# immediately and reconciles with the server asynchronously, which is the whole
# game when RTT is high -- a satellite connection sits near 700ms, where plain
# ssh echoes each character about a second after you type it. Separately, mosh
# diffs the screen at a capped frame rate, so streaming output (Claude Code
# emitting tokens) arrives as fewer, larger repaints instead of every
# incremental byte.
#
# No ServerAlive* here, unlike cplan. Those exist to make ssh give up FAST so
# the term-sane cleanup can run; mosh inverts that goal -- its UDP session
# survives network drops, sleep, and roaming, and resumes when connectivity
# returns, so there is nothing to tear down. ConnectTimeout still guards the
# one-shot ssh bootstrap that launches mosh-server.
#
# The command is passed as argv rather than as a string: mosh execs it directly
# instead of handing it to a remote shell, so this needs none of the nested
# quoting cplan's ssh form does. Still `zsh -ic` for the same reason as cplan --
# linux/source/50_ssh_agent.sh only re-points the stable SSH_AUTH_SOCK symlink
# from an interactive login. mosh always allocates a pty, so no -t.
#
# Tradeoffs, none fatal but worth knowing:
#
#   - No agent forwarding. mosh has no equivalent of ForwardAgent, so the box
#     falls back to its shared local agent (50_ssh_agent.sh handles this) and
#     may prompt once for the key passphrase. Box-side git still works.
#   - No port forwarding. `ssh -O forward -L ...` dev-server tunnels need a
#     plain ssh alongside; the ControlMaster block in ~/.ssh/config covers it.
#     The mac-bridge is unaffected -- autossh owns that tunnel independently.
#   - `pbcopy` breaks. It emits OSC 52, tmux re-emits it, and mosh 1.4.0 only
#     accepts the `c;` form that tmux does not send. Fails silently, as pbcopy
#     always does. `pbpaste` is fine (it uses the bridge, not the terminal).
#   - No scrollback in the mosh client itself; use tmux copy-mode.
#
# Truecolor needs mosh >= 1.4.0 on BOTH ends or the Catppuccin bar quantizes.
# Debian ships exactly 1.4.0; keep brew's matched to it.
#
# Prediction defaults to `adaptive`, which already shows predictions once the
# link is slow -- so there is nothing to set for the case this function exists
# for. Force it with mosh's own env var if you want it unconditionally:
# `export MOSH_PREDICTION_DISPLAY=always` (values: adaptive, always, never).
#
# If mosh refuses to start complaining about the locale, that is the classic
# failure: it passes the client's locale to mosh-server and rejects non-UTF-8.
# source/10_unicode.sh sets en_US.UTF-8 on both ends, so this should not bite.
#
# --predict-overwrite is on by default because of tmux. mosh-client has no idea
# tmux exists -- it sees one flat character grid -- so its default INSERTING
# prediction shifts the rest of the row rightward, and in a vertically split
# window that row is the divider and the neighbouring pane. Typing on the left
# visibly distorts the same line on the right. Overwrite mode predicts in place,
# so there is nothing to push sideways. Added in mosh 1.4.0 as "non-inserting
# prediction". Turn it off without editing this file:
#
#     MCPLAN_PREDICT_OVERWRITE=0 mcplan
#
# Related knob, mosh's own: MOSH_PREDICTION_DISPLAY=never disables predictive
# echo entirely. Worth reaching for once the link is good -- adaptive prediction
# switches on above 30ms SRTT and only back off at 20ms (terminaloverlay.h,
# SRTT_TRIGGER_HIGH/LOW), so a cross-country hop near 70ms keeps predicting
# forever. Above 80ms it also underlines predictions, clearing only at 50ms.
mcplan() {
  local host="${CPLAN_HOST:-claudes-plan}" rc
  local -a predict
  [[ "${MCPLAN_PREDICT_OVERWRITE:-1}" == 0 ]] || predict=(--predict-overwrite)
  if ! command -v mosh > /dev/null 2>&1; then
    echo "mcplan: mosh not installed -- brew install mosh (needs >= 1.4.0)" >&2
    return 127
  fi
  term-sane  # clear any junk modes left by a previous dropped connection
  mosh "${predict[@]}" --ssh="ssh -o ConnectTimeout=10" "$host" -- zsh -ic "tmux new -A -s main"
  rc=$?
  term-sane  # the remote tmux never got to undo its modes; do it locally
  return $rc
}
