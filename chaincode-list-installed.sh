#!/usr/bin/env bash

source lib.sh
usageMsg="$0 org [channel]"

org=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
channel=${2:-common}

#COMPOSE_PROJECT_NAME=${org} ORG=$org docker-compose exec cli.peer bash -c \
# "source container-scripts/lib/container-lib.sh 2>/dev/null; source ../lib/container-lib.sh 2>/dev/null; \
# listChaincodesInstalled $channel $org"

ORG=${org} PEER0_PORT=${PEER0_PORT:-7051} DOMAIN=${DOMAIN:-example.com} ORDERER_DOMAIN=${ORDERER_DOMAIN:-${DOMAIN:-example.com}} \
 runCLI "container-scripts/network/chaincode-list-installed.sh $channel $org" 