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
fi

