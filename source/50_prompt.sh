[[ -o interactive ]] || return

# Loud badge when this shell is root -- rendered by the env_var module in
# config/starship.toml. Computed once here (not a per-prompt subprocess); a
# non-root shell leaves it unset so the module renders nothing.
if (( EUID == 0 )); then
  export STARSHIP_ROOT_BADGE=' ROOT '
else
  unset STARSHIP_ROOT_BADGE
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  # starship binary missing -- re-run ./install to bootstrap it. Minimal
  # fallback prompt in the meantime.
  PROMPT='[%n@%m %~]%# '
  print -P "%F{yellow}⚠ starship not found; using fallback prompt. Run ./install.%f"
fi
