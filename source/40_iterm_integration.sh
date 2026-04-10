[[ -o interactive ]] || return

# iTerm2 shell integration for zsh.
# Install via: iTerm2 menu → Install Shell Integration
if [[ -f ~/.iterm2_shell_integration.zsh ]]; then
  source ~/.iterm2_shell_integration.zsh
fi
