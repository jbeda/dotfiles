[[ -o interactive ]] || return

# Loud badge when this shell is root -- rendered by the env_var module in
# config/starship.toml. Computed once here (not a per-prompt subprocess); a
# non-root shell leaves it unset so the module renders nothing.
if (( EUID == 0 )); then
  export STARSHIP_ROOT_BADGE=' ROOT '
else
  unset STARSHIP_ROOT_BADGE
fi

# Deterministic per-host color: hash the short hostname into a curated
# 256-color palette so every machine you land on shows a distinct, stable
# hostname color -- a glance tells you where you are. The colored string (ANSI
# baked in) is printed by the env_var module in config/starship.toml; Starship
# wraps the escapes in %{ %} for zsh, so prompt width stays correct. Edit the
# palette to taste; order changes which host gets which color.
() {
  local -a palette=(39 208 76 170 214 44 141 203 113 178 168 74 220 129 48 202)
  local host=${${(%):-%m}:-${HOST%%.*}}      # short hostname
  local sum=$(print -rn -- "$host" | cksum); sum=${sum%% *}
  local color=${palette[$(( sum % ${#palette} + 1 ))]}   # zsh arrays are 1-based
  export STARSHIP_HOST=$'\e[1;38;5;'${color}$'m'${host}$'\e[0m'
}

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  # starship binary missing -- re-run ./install to bootstrap it. Minimal
  # fallback prompt in the meantime.
  PROMPT='[%n@%m %~]%# '
  print -P "%F{yellow}⚠ starship not found; using fallback prompt. Run ./install.%f"
fi
