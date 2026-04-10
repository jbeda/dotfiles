# Ghostty shell integration.
# GHOSTTY_RESOURCES_DIR is set by Ghostty when spawning a shell directly.
# Sourcing this enables prompt marks, working directory reporting, and title updates.
if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi
