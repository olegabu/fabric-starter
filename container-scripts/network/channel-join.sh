#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

env|sort
channelName=${1:?Channel name is required}
downloadOrdererMSP ${ORDERER_NAME}
joinChannel "$channelName"
