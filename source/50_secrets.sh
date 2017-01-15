if [[ -d "${HOME}/.secrets/" ]]; then
  for file in "${HOME}/.secrets/"*; do
    source "$file"
  done
fi
