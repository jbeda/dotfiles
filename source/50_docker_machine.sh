if type docker-machine >& /dev/null && [[ $(uname -s) == "Darwin" ]]; then
  if [[ $(docker-machine status dev) == "Running" ]]; then
    eval $(boot2docker env dev 2>/dev/null)
  else
    echo "WARNING: docker-machine not running.  Start with 'start-docker-machine'."
  fi

  function start-docker-machine {
    docker-machine start dev
    eval $(boot2docker env dev 2>/dev/null) 
  }

  function fix-docker-machine-clock {
    docker-machine ssh dev "sudo date -u -D '%Y%m%d%H%M.%S' --set \"$(date -u +%Y%m%d%H%M.%S)\"" >/dev/null
  }
fi
