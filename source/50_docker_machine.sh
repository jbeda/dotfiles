if type docker-machine >& /dev/null && [[ $(uname -s) == "Darwin" ]]; then
  if [[ $(docker-machine status dev) == "Running" ]]; then
    eval $(docker-machine env dev 2>/dev/null)
  else
    echo "WARNING: docker-machine not running.  Start with 'start-docker-machine'."
  fi

  function start-docker-machine {
    docker-machine start dev
    eval $(docker-machine env dev 2>/dev/null) 
  }

  function fix-docker-machine-clock {
    docker-machine ssh dev "sudo date -u -D %s --set $(date -u +%s)" >/dev/null
  }
fi
