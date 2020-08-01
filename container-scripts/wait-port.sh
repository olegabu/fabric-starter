#!/usr/bin/env bash

host=$1
port=$2

date
while :
   do
      set -x
      nc $host $port -z
      RES=$?
      set +x
      if [[ $RES -eq 0 ]]; then
           echo "Wait completed"
           date
           break
      fi
      echo "Status: $1. Waiting "
      sleep 1
   done