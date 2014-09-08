if type boot2docker >& /dev/null; then
  if [[ $(boot2docker status) == "running" ]]; then
    export DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375
  else
    echo "WARNING: boot2docker not running."
  fi
fi
