# Reverse-SSH mac-bridge

Reach back to your **Mac** from an SSH session on this Linux box, over a single
reverse-forwarded port. One launchd listener on the Mac reads one
`verb<TAB>args` line and dispatches it (via the on-disk `dispatch` script — see
below). Three verbs today:

- **`open <url>`** — open a URL in the Mac browser (`linux/bin/browse`)
- **`code <host> <path>`** — open VS Code on the Mac attached to a dir on this
  box, via `code --remote ssh-remote+<host> <path>` (`linux/bin/code-mac`)
- **`clip-image <host> <path>`** — grab the Mac's clipboard image (`pngpaste`)
  and `scp` it to `<host>:<path>` on the box, so you can hand the path to
  Claude Code, which loads an image from a plain path (`linux/bin/paste-image`,
  bound to `C-Spc i` in tmux)

```
box browse/code-mac/paste-image  ──writes "verb<TAB>args"──▶  127.0.0.1:17603 (box)
        │ a dedicated autossh reverse tunnel (RemoteForward) carries the port
        │ back to the Mac and redials itself after sleep / a network change
        ▼
   127.0.0.1:17603 (Mac) ──launchd──▶ dispatch: open <url> | code … | scp clipboard.png
```

The verbs use the tunnel differently. `open` is fully served over the reverse
tunnel. `code` and `clip-image` use it only as a **trigger**: the Mac then opens
its *own* fresh SSH connection back to `<host>` — VS Code's `--remote` for
`code`, `scp` for `clip-image` — so the Mac must be able to `ssh <host>`
directly (it already can, that's how you log into the box).

### The dispatch script

The launchd plist stays a trivial static stub: it just
`exec "$HOME/src/dotfiles/darwin/mac-bridge/dispatch"` and hands that script the
socket on stdin/stdout. All the request parsing, per-verb validation, and the
actual commands live in `dispatch` (a normal `/bin/sh` script) so they're
readable and `shellcheck`-able instead of crammed into an XML string. Add or
change a verb there, not in the plist. (`clip-image` needs `pngpaste`:
`brew install pngpaste`.)

The Linux side (`linux/bin/browse`, `linux/bin/code-mac`,
`linux/source/50_mac_bridge.sh`) installs with the normal `./install` (which
links `linux/bin/` into `~/.local/bin` only on Linux). The Mac side is a
one-time setup, scripted below.

## Mac setup (run on the Mac, once)

The `setup-mac` script links and loads the launchd listener, migrates the old
`browser-bridge` agent if present, self-tests it, and prints the `~/.ssh/config`
lines to add by hand. It doesn't edit `~/.ssh/config` — dropping a few lines
into the right host block once is simpler and safer than teaching a script to
merge into multi-name `Host` lines. It's idempotent, so re-run it any time (e.g.
to reload after editing the plist).

```sh
~/src/dotfiles/darwin/mac-bridge/setup-mac claudes-plan   # alias is only for the printed hint
```

Then add the printed lines to `~/.ssh/config`. There are now **two** blocks —
your normal interactive/VS Code block, and a dedicated tunnel block the
always-on autossh job dials (see [Persistence](#persistence-across-sleep--roaming)):

```sshconfig
# Interactive + VS Code. Keepalives so a dead link is detected and torn down
# fast (no orphaned VS Code server / stale ControlMaster). NO RemoteForward here
# — the tunnel block below owns port 17603; two owners collide on it.
Host claudes-plan
    HostName claudes-plan.<your-tailnet>.ts.net
    ForwardAgent yes
    ControlMaster auto
    ControlPath ~/.ssh/cm-%C
    ControlPersist 10m
    ServerAliveInterval 20
    ServerAliveCountMax 3
    TCPKeepAlive yes

# Dedicated bridge tunnel. autossh (via launchd) holds this open and redials it
# after sleep / a network change. It owns the RemoteForward, dies loudly if it
# can't bind the port (so autossh notices and restarts), and never multiplexes.
Host claudes-plan-tunnel
    HostName claudes-plan.<your-tailnet>.ts.net
    ForwardAgent no
    ControlMaster no
    ControlPath none
    RemoteForward 17603 127.0.0.1:17603
    ExitOnForwardFailure yes
    ServerAliveInterval 20
    ServerAliveCountMax 3
```

> **Why the Tailscale MagicDNS FQDN for `HostName`:** it resolves and routes on
> *every* network you roam to, and Tailscale gives a **direct** peer-to-peer path
> in each — the LAN path when you're home, NAT-traversal when you're not (not a
> DERP relay) — so there's no performance reason to prefer a raw-LAN name. A
> home-only DNS name would just fail to reconnect at work. The one dependency:
> `tailscaled` must be up on both ends. `Host` stays the short alias you type
> (`ssh claudes-plan`); only `HostName` is the FQDN. The short MagicDNS name
> (`claudes-plan`) also works if your tailnet's search domain is applied, but the
> full FQDN is failsafe. Keep the tunnel block named exactly `claudes-plan-tunnel`
> — the launchd plist dials that literal alias.

`ControlMaster`/`ControlPath`/`ControlPersist` multiplex interactive + VS Code ssh
onto one shared connection, which makes `code --remote` (and any `ssh -O forward
-L …` dev-server tunnels) instant instead of re-handshaking. `%C` hashes
user/host/port into a short socket name (macOS has a ~104-char socket-path limit).
The tunnel block deliberately opts out of multiplexing (`ControlMaster no`) so it
stays an independent, always-up connection.

For the `code` verb you also need, on the Mac:

- VS Code's **`code` CLI on PATH** — Command Palette → *Shell Command: Install
  'code' command in PATH*.
- The **Remote - SSH** extension (`ms-vscode-remote.remote-ssh`).

For the `clip-image` verb you also need, on the Mac:

- **`pngpaste`** — `brew install pngpaste`. It reads the clipboard image;
  without it, `paste-image` from the box just times out with "no image".

Finally **reconnect** your SSH session and, from the Linux box:

```sh
browse https://example.com     # opens in the Mac browser
code-mac                       # opens VS Code on the Mac, attached to $PWD here
code-mac ~/src/someproject     # ...attached to that dir
paste-image                    # pull the Mac clipboard image here, print its path
```

For images, the ergonomic entry point is the tmux binding **`C-Spc i`**: it runs
`paste-image` and types the resulting path straight into the current pane — e.g.
into a Claude Code prompt, which loads an image from a plain path. Copy/screenshot
an image on the Mac, press `C-Spc i`, and the path appears in your prompt; add
your question and send. The round-trip blocks briefly; on no-image/bridge-down it
types nothing and flashes a message.

### Which host does `code-mac` tell VS Code to use?

`code-mac` sends `$MAC_SSH_HOST` as the `<host>` in `ssh-remote+<host>`, so it
must be the **Mac's** ssh Host alias for this box. It defaults to `hostname -s`;
if that isn't your ssh alias, override it in `~/.zsh.local`:

```sh
export MAC_SSH_HOST=claudes-plan
```

### What it does, by hand

If you'd rather not run the script:

1. **Load the listener + the always-on tunnel**
   ```sh
   brew install autossh                       # the tunnel needs it
   mkdir -p ~/Library/LaunchAgents
   for L in com.jbeda.mac-bridge com.jbeda.mac-bridge-tunnel; do
     ln -sf ~/src/dotfiles/darwin/mac-bridge/$L.plist ~/Library/LaunchAgents/$L.plist
     launchctl load ~/Library/LaunchAgents/$L.plist
   done
   launchctl list | grep mac-bridge           # should show both labels
   ```
2. **Add the ssh config blocks shown above** — keepalives on the interactive
   block (no `RemoteForward`), plus the dedicated `claudes-plan-tunnel` block
   whose `RemoteForward 17603 127.0.0.1:17603` binds 17603 on the box and tunnels
   it to `127.0.0.1:17603` on the Mac (loopback only). Add the box-side
   `sshd_config.d/10-keepalive.conf` from
   [Persistence](#persistence-across-sleep--roaming).

Inside an SSH session, `open` and `xdg-open` are aliased to `browse` too, and
`$BROWSER=browse`, so tools like `gh`, `python -m webbrowser`, and `xdg-open`
route through it automatically.

## Persistence across sleep / roaming

A laptop that sleeps and moves between networks (home ↔ work) *will* drop its
SSH/TCP sessions — nothing keeps a single connection alive across a multi-hour
sleep plus an IP change. The goal is **auto-heal**, not immortality: each piece
re-establishes itself instead of needing a manual re-ssh and stale-state cleanup.

Three layers cooperate:

1. **The bridge** — the `com.jbeda.mac-bridge-tunnel` launchd job runs
   `autossh -M 0 -N claudes-plan-tunnel`. autossh restarts the inner ssh when the
   Host block's `ServerAliveInterval` probes find the link dead; launchd restarts
   autossh if it ever exits. So port 17603 is forwarded whenever the Mac can reach
   the box, independent of any interactive or VS Code session. Needs
   `brew install autossh`. Logs: `/tmp/mac-bridge-tunnel.log`.
2. **Fast, clean teardown** — `ServerAliveInterval`/`ServerAliveCountMax` on the
   Mac (both Host blocks) and matching `ClientAliveInterval`/`ClientAliveCountMax`
   on the box's sshd declare a dead session in ~60s. That's what stops sleep/roam
   drops from leaving an **orphaned VS Code server** or a **stale ControlMaster**
   holding the port — the failure mode where "the terminal works but VS Code and
   `code-mac` don't." Server side, one time:
   ```sh
   sudo tee /etc/ssh/sshd_config.d/10-keepalive.conf >/dev/null <<'CONF'
   ClientAliveInterval 20
   ClientAliveCountMax 3
   TCPKeepAlive yes
   CONF
   sudo sshd -t && sudo systemctl reload ssh   # reload; existing sessions unaffected
   ```
3. **The terminal** — tmux already persists your work; you just reattach. The
   `cplan` alias (`darwin/source/50_cplan.sh`) collapses "ssh in, then `ta`" into
   one command, and does it via an *interactive* login so the box's SSH-agent
   symlink gets re-pointed (a bare `ssh -t box tmux attach` skips that and breaks
   box-side git auth).

VS Code Remote-SSH still opens its own connection and can't survive a sleep
transparently — but with the keepalives above, reconnect is fast and the
"Kill VS Code Server on Host" dance becomes rare rather than routine.

## Troubleshooting

- **`nothing is listening on 127.0.0.1:17603`** — the tunnel or the Mac listener
  is down. Check the tunnel: `launchctl list | grep mac-bridge-tunnel` (should
  show the label with PID) and `tail /tmp/mac-bridge-tunnel.log`; a common cause
  is autossh missing (`brew install autossh`) or the tunnel's `HostName` not
  resolving on the current network (use the Tailscale name). Confirm the port is
  bound on the box: `ss -tlnp | grep 17603` should show a listener. Check the
  Mac listener with `launchctl list | grep mac-bridge`.
- **`code-mac` opens nothing** — the listener got the trigger but `code --remote`
  failed on the Mac. Check the `code` CLI is on PATH and the Remote - SSH
  extension is installed, and that `MAC_SSH_HOST` matches a Host the Mac can ssh
  to. Test the underlying command directly on the Mac:
  `code --remote ssh-remote+claudes-plan /home/jbeda/src/dotfiles`.
- **Port already in use on the remote** — a stale ssh session still holds 17603,
  so the tunnel's `ExitOnForwardFailure yes` makes autossh exit and retry without
  ever binding. Usually it's a leftover interactive session that still has an old
  `RemoteForward` line — remove `RemoteForward` from the interactive Host block
  (only the tunnel block should have it), and drop the stale connection
  (`ssh -O exit claudes-plan`, or find the holder on the box with
  `ss -tlnp | grep 17603`).
- **Tunnel flapping / won't stay up** — `tail -f /tmp/mac-bridge-tunnel.log`. If
  auth fails, the launchd-run ssh can't read your key: make sure it's in the
  keychain (`UseKeychain yes` + `AddKeysToAgent yes` in `~/.ssh/config`) so it
  loads without an interactive agent. `launchctl kickstart -k gui/$(id -u)/com.jbeda.mac-bridge-tunnel`
  forces a restart after fixing config.
- **Change the port** — set it in four places: the plist `SockServiceName`, both
  the interactive-block (removed) and tunnel-block `RemoteForward` line, the
  `autossh` alias's `RemoteForward`, and `MAC_BRIDGE_PORT` in
  `linux/source/50_mac_bridge.sh`.

## Security

The listener binds to `127.0.0.1` and only accepts three verbs, each validated
in `dispatch`: `open` runs `open` only for `http://` / `https://` URLs (no
`file://` or app-scheme URLs); `code` and `clip-image` both require the host to
be a bare ssh-alias (`[A-Za-z0-9._-]`) and the path to be absolute before running
`code --remote` / `scp`. Any local process on the Mac could still drive these,
but the surface is limited to "open a web URL", "open VS Code on an ssh host",
and "scp the clipboard image to an ssh host" — all low-risk on a personal
machine.
