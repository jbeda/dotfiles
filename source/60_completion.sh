[[ -o interactive ]] || return

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
