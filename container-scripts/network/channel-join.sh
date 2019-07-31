#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

usageMsg="$0 channelName "
exampleMsg="$0 common "


channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
downloadOrdererMSP ${ORDERER_NAME}
joinChannel "$channelName"
