# macOS (Apple Silicon) and Linux (Linuxbrew) prefixes; whichever exists wins.
if [ -d "/opt/homebrew/bin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
