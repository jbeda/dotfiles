if type boot2docker >& /dev/null; then
  if [[ $(boot2docker status) == "running" ]]; then
    $(boot2docker shellinit 2>/dev/null)
  else
    echo "WARNING: boot2docker not running."
  fi
fi
