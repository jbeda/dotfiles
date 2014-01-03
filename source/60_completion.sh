# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -f /brew/etc/bash_completion ]; then
    . /brew/etc/bash_completion
  fi

  # SSH auto-completion based on entries in known_hosts.
  if [ -f ~/.ssh/known_hosts ]; then
    complete -o default -W "$(cat ~/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp sftp
  fi

  # Bash completion for CLOUD_SDK
  [ -f $CLOUD_SDK_DIR/arg_rc ] && source $CLOUD_SDK_DIR/arg_rc
fi
