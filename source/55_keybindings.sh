[[ -o interactive ]] || return

# Emacs-style line editing
bindkey -e

# Make ESC-Backspace stop at path separators (treat / as a word boundary)
WORDCHARS=${WORDCHARS/\//}

# Up/down arrow: search history by the prefix typed so far.
# e.g. type "git" then press Up to cycle through previous git commands only.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search   # Up arrow
bindkey '^[[B' down-line-or-beginning-search # Down arrow
bindkey '^[OA' up-line-or-beginning-search   # Up arrow (alternate sequence)
bindkey '^[OB' down-line-or-beginning-search # Down arrow (alternate sequence)

# Home / End / Delete
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
