#!/usr/bin/env bash

host=$1
port=$2

if [ -n "${port}" ]; then
  date
  echo "Waiting for server is accessible: ${host}:${port}"
  while :; do
    set -x
    nc $host $port -z
    RES=$?
    set +x
    if [[ $RES -eq 0 ]]; then
      echo "Probe of ${host}:${port} is successful"
      date
      break
    fi
    echo "Status: $RES. Waiting for ${host}:${port}"
    sleep 1
  done
fi
