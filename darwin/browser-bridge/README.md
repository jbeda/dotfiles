# Reverse-SSH browser bridge

Open URLs from this remote Linux box in the browser on your **Mac** — so
clicking/printing a link in an SSH session (or an agent that runs `open <url>`)
pops your local browser.

```
remote `browse <url>`  ──writes──▶  127.0.0.1:17603 (remote)
        │ SSH RemoteForward tunnels the port back to the Mac
        ▼
   127.0.0.1:17603 (Mac) ──launchd──▶  /usr/bin/open <url>
```

The Linux side (`bin/browse`, `linux/source/50_browser_bridge.sh`) installs with
the normal `./install` (linking `bin/browse` into `~/.local/bin`). The Mac side
is a one-time setup, scripted below.

## Mac setup (run on the Mac, once)

The `setup-mac` script links and loads the launchd listener, self-tests it, and
prints the `RemoteForward` line for you to add to `~/.ssh/config` by hand. It
doesn't edit `~/.ssh/config` — dropping one line into the right host block once
is simpler and safer than teaching a script to merge into multi-name `Host`
lines. It's idempotent, so re-run it any time (e.g. to reload after editing the
plist).

```sh
~/src/dotfiles/darwin/browser-bridge/setup-mac claudes-plan   # alias is only for the printed hint
```

Then add the printed line **inside your existing host block** (don't create a
second `Host` block — SSH accumulates `RemoteForward` across matching blocks,
but a per-name block only applies when you connect using that exact name):

```sshconfig
Host claudes-plan claudes-plan.h.bedafamily.com
    Hostname claudes-plan.h.bedafamily.com
    ForwardAgent yes
    RemoteForward 17603 127.0.0.1:17603
```

Finally **reconnect** your SSH session and, from the Linux box:

```sh
browse https://example.com     # opens on your Mac
```

### What it does, by hand

If you'd rather not run the script:

1. **Load the listener**
   ```sh
   mkdir -p ~/Library/LaunchAgents
   ln -sf ~/src/dotfiles/darwin/browser-bridge/com.jbeda.browser-bridge.plist \
          ~/Library/LaunchAgents/com.jbeda.browser-bridge.plist
   launchctl load ~/Library/LaunchAgents/com.jbeda.browser-bridge.plist
   launchctl list | grep browser-bridge      # should show the label
   ```
2. **Forward the port** — add to the host block in `~/.ssh/config`:
   ```sshconfig
   Host claudes-plan                      # <- match your actual Host alias
       RemoteForward 17603 127.0.0.1:17603
   ```
   `RemoteForward <remote-port> <mac-host:mac-port>` binds port 17603 on the
   Linux box and tunnels it to `127.0.0.1:17603` on the Mac (loopback only).

Inside an SSH session, `open` and `xdg-open` are aliased to `browse` too, and
`$BROWSER=browse`, so tools like `gh`, `python -m webbrowser`, and `xdg-open`
route through it automatically.

## Troubleshooting

- **`browse: nothing is listening on 127.0.0.1:17603`** — the tunnel or the Mac
  listener is down. Check `launchctl list | grep browser-bridge` on the Mac and
  confirm the SSH session actually forwarded the port (`ss -tlnp | grep 17603`
  on the Linux box should show a listener while connected).
- **Port already in use on the remote** — another/older SSH session still holds
  the RemoteForward. Use `ExitOnForwardFailure no` (default) so it's non-fatal,
  or drop the stale connection.
- **Change the port** — set it in three places: the plist `SockServiceName`, the
  `RemoteForward` line, and `BROWSER_BRIDGE_PORT` in `linux/source/50_browser_bridge.sh`.

## Security

The listener binds to `127.0.0.1` and only runs `open` for `http://` / `https://`
URLs, so it can't be used to open `file://` or custom app schemes. Any local
process on the Mac could still ask it to open a web URL; that's the intended,
low-risk surface.
