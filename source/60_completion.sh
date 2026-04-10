# Add Homebrew completions to FPATH before initializing the completion system
if command -v brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Initialize zsh completion system
autoload -Uz compinit && compinit

# SSH auto-completion based on entries in known_hosts
if [[ -f ~/.ssh/known_hosts ]]; then
  zstyle ':completion:*:(ssh|scp|sftp):*' hosts \
    $(cat ~/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')
fi
