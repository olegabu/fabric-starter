#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName "
exampleMsg="$0 common "

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} ORDERER_NAME=${ORDERER_NAME} runCLI "container-scripts/network/channel-create.sh $channelName"

sleep 1