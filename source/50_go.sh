if [[ -d "$HOME/goroot" && ! -n ${GOROOT+_} ]]; then
  export GOROOT="$HOME/goroot"
  export PATH="${GOROOT}/bin:${PATH}"
fi

export GOPATH=${GOPATH:-"$HOME/src/go"}
