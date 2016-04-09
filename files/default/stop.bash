#!/usr/bin/env bash

declare pid

function stop-and-wait() {
  if ps "$pid" &> /dev/null; then
    if kill -TERM "$pid" &> /dev/null; then
      while ps "$pid" &> /dev/null; do
        sleep 1;
      done
      exit 0
    else
      exit 1
    fi
  else
    exit 0
  fi
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
  stop-and-wait
else
  echo "Missing --pid option"
  exit 1
fi
