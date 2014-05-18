if [ -d "/brew/bin" ]; then
  PATH="/brew/bin:$PATH"
fi
if [ -d "/brew/sbin" ]; then
  PATH="/brew/sbin:$PATH"
fi

# Make /usr/local/bin come earlier on the path to make brew on OSX work well
# when installed there.
if [ -d "/usr/local/bin" ]; then
  PATH="/usr/local/bin:$PATH"
fi
if [ -d "/usr/local/sbin" ]; then
  PATH="/usr/local/sbin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/src/go/bin" ] ; then
    PATH="$HOME/src/go/bin:$PATH"
fi
