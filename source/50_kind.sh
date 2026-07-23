[[ -o interactive ]] || return

# Wrap kind so `kind create cluster` without an explicit --config picks up
# the default dev config (etcd fsync disabled; see config/kind/dev.yaml).
# Announces itself so a cluster's provenance is never a mystery. Scripts
# calling kind non-interactively bypass this and get stock behavior.
kind() {
  if [[ "$1" == "create" && "$2" == "cluster" && "$*" != *--config* \
        && -f ~/.config/kind/dev.yaml ]]; then
    echo "kind: applying default config ~/.config/kind/dev.yaml (etcd fsync off)" >&2
    command kind "$@" --config ~/.config/kind/dev.yaml
  else
    command kind "$@"
  fi
}
