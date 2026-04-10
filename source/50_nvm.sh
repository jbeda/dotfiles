export NVM_DIR="$HOME/.nvm"

if [[ -o interactive ]]; then
  # Lazy-load for interactive shells to avoid ~300ms startup cost.
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
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
else
  # Non-interactive: load eagerly so node/npm are in PATH for scripts.
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
fi
