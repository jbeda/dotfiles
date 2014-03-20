if [ -d "/brew/bin" ]; then
  PATH="/brew/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/src/go/bin" ] ; then
    PATH="$HOME/src/go/bin:$PATH"
fi
