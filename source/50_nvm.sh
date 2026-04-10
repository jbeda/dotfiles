[[ -o interactive ]] || return

export NVM_DIR="$HOME/.nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # Lazy-load nvm on first use to avoid ~300ms startup cost on every shell.
  # Stubs for nvm, node, npm, and npx each trigger the real load then call through.
  _nvm_load() {
    unset -f nvm node npm npx _nvm_load
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  }
  nvm()  { _nvm_load; nvm "$@"; }
  node() { _nvm_load; node "$@"; }
  npm()  { _nvm_load; npm "$@"; }
  npx()  { _nvm_load; npx "$@"; }
fi
