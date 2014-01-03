# Source all files in ~/.dotfiles/source/
function src() {
  local file
  if [[ "$1" ]]; then
    source "$HOME/src/dotfiles/source/$1.sh"
  else
    for file in ~/src/dotfiles/source/*; do
      source "$file"
    done
  fi
}

src
