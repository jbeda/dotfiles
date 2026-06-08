if [[ -d "$HOME/goroot" && ! -n ${GOROOT+_} ]]; then
  export GOROOT="$HOME/goroot"
  export PATH="${GOROOT}/bin:${PATH}"
fi

export GOPATH=${GOPATH:-"$HOME/src/go"}

# Modules matching these globs skip Google's public proxy + checksum DB and are
# fetched directly from their git source (using local git creds). Needed for
# private/internal org repos.
export GOPRIVATE="github.com/stacklok/*,github.com/stackloklabs/*"
