#!/usr/bin/env bash

declare pid

function check-running() {
  local tries=0
  local max_tries=5
  while [ $tries -le $max_tries ]; do
    if netstat --numeric --listen --programs --tcp 2> /dev/null | grep -q "$pid/java"; then
      exit 0
    fi
    tries=$((tries + 1))
    sleep 1
  done
}

case "$1" in
  --pid=*)
    pid="${1#*=}"
    ;;
  *)
    echo "Unkown option: $1"
    exit 1
    ;;
esac

if [ -n "$pid" ]; then
  check-running
else
  echo "Missing --pid option"
  exit 1
fi
