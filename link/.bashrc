DOTFILES_ROOT="${HOME}/src/dotfiles"

function src() {
  local file
  if [[ "$1" ]]; then
    source "${DOTFILES_ROOT}/source/$1.sh"
  else
    for file in "${DOTFILES_ROOT}/source/"*; do
      source "$file"
    done
  fi
}

src
