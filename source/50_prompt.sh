[[ -o interactive ]] || return

# Loud badge when this shell is root -- rendered by the env_var module in
# config/starship.toml. Computed once here (not a per-prompt subprocess); a
# non-root shell leaves it unset so the module renders nothing.
if (( EUID == 0 )); then
  export STARSHIP_ROOT_BADGE=' ROOT '
else
  unset STARSHIP_ROOT_BADGE
fi

# Deterministic per-host color: hash the short hostname into a curated palette
# so every machine you land on shows a distinct, stable hostname color -- a
# glance tells you where you are. The colored string (ANSI baked in) is printed
# by the env_var module in config/starship.toml; Starship wraps the escapes in
# %{ %} for zsh, so prompt width stays correct. Edit the palette to taste;
# order changes which host gets which color.
#
# Catppuccin Mocha accents as 24-bit "R;G;B". Nine of Mocha's fourteen, not all:
# rosewater and flamingo are near-white and would read as ordinary text, and
# maroon/sky/lavender sit right next to red/teal/blue. A palette whose entries
# you can't tell apart at a glance defeats the whole point, so this trades
# fewer colors for ones that are actually separable -- one per hue family.
#
# These emit truecolor, which needs the terminal to support it. Ghostty does,
# and link/.tmux.conf asserts it for tmux's children; a 256-color terminal will
# quantize them to the nearest palette entry rather than break.
() {
  local -a palette=(
    '243;139;168'   # red
    '250;179;135'   # peach
    '249;226;175'   # yellow
    '166;227;161'   # green
    '148;226;213'   # teal
    '116;199;236'   # sapphire
    '137;180;250'   # blue
    '203;166;247'   # mauve
    '245;194;231'   # pink
  )
  local host=${${(%):-%m}:-${HOST%%.*}}      # short hostname
  local sum=$(print -rn -- "$host" | cksum); sum=${sum%% *}
  local color=${palette[$(( sum % ${#palette} + 1 ))]}   # zsh arrays are 1-based
  export STARSHIP_HOST=$'\e[1;38;2;'${color}$'m'${host}$'\e[0m'
}

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  # starship binary missing -- re-run ./install to bootstrap it. Minimal
  # fallback prompt in the meantime.
  PROMPT='[%n@%m %~]%# '
  print -P "%F{yellow}⚠ starship not found; using fallback prompt. Run ./install.%f"
fi
