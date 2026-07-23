[[ -o interactive ]] || return

# Generate completions for tools that emit their own and don't come from a
# package manager that ships completion files (go install, curl installers).
# Regenerated only when missing or older than the tool's binary.
() {
  local comp_dir=$HOME/.local/share/zsh/completions
  local spec tool gen_cmd target regen=0
  local -a specs=(
    'task:task --completion zsh'
    'mise:mise completion zsh'
    'starship:starship completions zsh'
    'uv:uv generate-shell-completion zsh'
    'uvx:uvx --generate-shell-completion zsh'
  )
  for spec in $specs; do
    tool=${spec%%:*}
    gen_cmd=${spec#*:}
    (( $+commands[$tool] )) || continue
    target=$comp_dir/_$tool
    if [[ ! -f $target || $commands[$tool] -nt $target ]]; then
      mkdir -p $comp_dir
      if ${(z)gen_cmd} >$target 2>/dev/null; then
        regen=1
      else
        rm -f $target
      fi
    fi
  done
  # New completion files won't be seen through a cached dump; force a rebuild.
  (( regen )) && rm -f ~/.zcompdump
  [[ -d $comp_dir ]] && FPATH="$comp_dir:$FPATH"
}

# Add Homebrew completions to FPATH before initializing the completion system
if command -v brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Initialize zsh completion system.
# Skip regenerating the dump file if it is less than 24 hours old (compinit -C).
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Scrollable interactive menu; colored list using LS_COLORS; case-insensitive matching
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Cache expensive completions (e.g. pip, kubectl)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zcompcache

# SSH auto-completion based on entries in known_hosts
if [[ -f ~/.ssh/known_hosts ]]; then
  zstyle ':completion:*:(ssh|scp|sftp):*' hosts \
    $(cat ~/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')
fi
