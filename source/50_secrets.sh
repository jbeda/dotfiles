for file in "${HOME}/.secrets/"*; do
  source "$file"
done
