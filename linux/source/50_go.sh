# /tmp on this box is tmpfs (16G, RAM-backed). Go's per-invocation work dirs
# (/tmp/go-buildNNNN) are meant to be removed on exit, but a killed build or
# test leaks one — they reached 8G+ of RAM before this was noticed. Point them
# at disk instead; `go clean` does not manage these, only $GOCACHE.
export GOTMPDIR="${XDG_CACHE_HOME:-$HOME/.cache}/go-tmp"
[[ -d "$GOTMPDIR" ]] || mkdir -p "$GOTMPDIR"
