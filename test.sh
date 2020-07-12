#!/usr/bin/env bash

port=$1

date > wait.txt
date
while :
   do
      set -x
      nc $MY_IP $port -z
      RES=$?
      set +x
      echo $RES
      echo $RES > end.txt
      if [[ $RES -eq 0 ]]; then
           echo "Wait completed" > end.txt
           echo "Wait completed"
           date >> end.txt
           date
           break
      fi
      echo "Waiting" >> wait.txt
      echo "Waiting"
      sleep 1
   done