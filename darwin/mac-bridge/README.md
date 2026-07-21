# Reverse-SSH mac-bridge

Reach back to your **Mac** from an SSH session on this Linux box, over a single
reverse-forwarded port. One launchd listener on the Mac reads one
`verb<TAB>args` line and dispatches it. Two verbs today:

- **`open <url>`** — open a URL in the Mac browser (`linux/bin/browse`)
- **`code <host> <path>`** — open VS Code on the Mac attached to a dir on this
  box, via `code --remote ssh-remote+<host> <path>` (`linux/bin/code-mac`)

```
box `browse <url>` / `code-mac <dir>`  ──writes "verb<TAB>args"──▶  127.0.0.1:17603 (box)
        │ SSH RemoteForward tunnels the port back to the Mac
        ▼
   127.0.0.1:17603 (Mac) ──launchd──▶  open <url>   |   code --remote ssh-remote+<host> <path>
```

Note the two verbs use the tunnel differently. `open` is fully served over the
reverse tunnel. `code` only uses it as a **trigger**: VS Code then opens its
*own* fresh SSH connection from the Mac to `<host>` and does the editing over
that — so the Mac must be able to `ssh <host>` directly (it already can, that's
how you log into the box).

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

Then add the printed lines **inside your existing host block** (don't create a
second `Host` block — SSH accumulates these across matching blocks, but a
per-name block only applies when you connect using that exact name):

```sshconfig
Host claudes-plan claudes-plan.h.bedafamily.com
    Hostname claudes-plan.h.bedafamily.com
    ForwardAgent yes
    ControlMaster auto
    ControlPath ~/.ssh/cm-%C
    ControlPersist 10m
    RemoteForward 17603 127.0.0.1:17603
```

`ControlMaster`/`ControlPath`/`ControlPersist` multiplex all ssh to the box onto
one shared connection. That's not strictly required, but it makes `code --remote`
(and any future `ssh -O forward -L …` dev-server tunnels) instant instead of
re-handshaking, and it stops a second ssh session from fighting over the
`RemoteForward` port. `%C` hashes user/host/port into a short socket name (macOS
has a ~104-char limit on socket paths).

For the `code` verb you also need, on the Mac:

- VS Code's **`code` CLI on PATH** — Command Palette → *Shell Command: Install
  'code' command in PATH*.
- The **Remote - SSH** extension (`ms-vscode-remote.remote-ssh`).

Finally **reconnect** your SSH session and, from the Linux box:

```sh
browse https://example.com     # opens in the Mac browser
code-mac                       # opens VS Code on the Mac, attached to $PWD here
code-mac ~/src/someproject     # ...attached to that dir
```

### Which host does `code-mac` tell VS Code to use?

`code-mac` sends `$MAC_SSH_HOST` as the `<host>` in `ssh-remote+<host>`, so it
must be the **Mac's** ssh Host alias for this box. It defaults to `hostname -s`;
if that isn't your ssh alias, override it in `~/.zsh.local`:

```sh
export MAC_SSH_HOST=claudes-plan
```

### What it does, by hand

If you'd rather not run the script:

1. **Load the listener**
   ```sh
   mkdir -p ~/Library/LaunchAgents
   ln -sf ~/src/dotfiles/darwin/mac-bridge/com.jbeda.mac-bridge.plist \
          ~/Library/LaunchAgents/com.jbeda.mac-bridge.plist
   launchctl load ~/Library/LaunchAgents/com.jbeda.mac-bridge.plist
   launchctl list | grep mac-bridge          # should show the label
   ```
2. **Forward the port + multiplex** — add the ssh config lines shown above.
   `RemoteForward <remote-port> <mac-host:mac-port>` binds port 17603 on the
   Linux box and tunnels it to `127.0.0.1:17603` on the Mac (loopback only).

Inside an SSH session, `open` and `xdg-open` are aliased to `browse` too, and
`$BROWSER=browse`, so tools like `gh`, `python -m webbrowser`, and `xdg-open`
route through it automatically.

## Troubleshooting

- **`nothing is listening on 127.0.0.1:17603`** — the tunnel or the Mac listener
  is down. Check `launchctl list | grep mac-bridge` on the Mac and confirm the
  SSH session actually forwarded the port (`ss -tlnp | grep 17603` on the Linux
  box should show a listener while connected).
- **`code-mac` opens nothing** — the listener got the trigger but `code --remote`
  failed on the Mac. Check the `code` CLI is on PATH and the Remote - SSH
  extension is installed, and that `MAC_SSH_HOST` matches a Host the Mac can ssh
  to. Test the underlying command directly on the Mac:
  `code --remote ssh-remote+claudes-plan /home/jbeda/src/dotfiles`.
- **Port already in use on the remote** — a stale ssh session still holds the
  RemoteForward. With `ControlMaster` this is rare (sessions share one
  connection); otherwise use `ExitOnForwardFailure no` (default) so it's
  non-fatal, or drop the stale connection.
- **Change the port** — set it in three places: the plist `SockServiceName`, the
  `RemoteForward` line, and `MAC_BRIDGE_PORT` in `linux/source/50_mac_bridge.sh`.

## Security

The listener binds to `127.0.0.1` and only accepts two verbs, each validated:
`open` runs `open` only for `http://` / `https://` URLs (no `file://` or
app-scheme URLs); `code` requires the host to be a bare ssh-alias
(`[A-Za-z0-9._-]`) and the path to be absolute before running `code --remote`.
Any local process on the Mac could still drive these, but the surface is limited
to "open a web URL" and "open VS Code on an ssh host" — both low-risk on a
personal machine.
