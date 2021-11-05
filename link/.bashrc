DOTFILES_ROOT="${HOME}/src/dotfiles"

function src() {
  local file
  local platform=$(echo $(uname -s) | tr '[:upper:]' '[:lower:]')

  if [[ -e "$HOME/.bash.local" ]]; then
    source "$HOME/.bash.local"
  fi

  if [[ "$1" ]]; then
    source "${DOTFILES_ROOT}/source/$1.sh"
  else
    for file in "${DOTFILES_ROOT}/source/"*; do
      source "$file"
    done
    if [[ -d "$DOTFILES_ROOT/$platform/source" ]]; then
      for file in "${DOTFILES_ROOT}/$platform/source/"/*; do
        source "$file"
      done
    fi
  fi
}

src

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
