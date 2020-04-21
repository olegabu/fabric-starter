#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}

printToLogAndToScreenCyan "Joining ${org}.${DOMAIN} to the [${channelName}] channel using API..." | printToLogAndToScreen 
JWT=$(APIAuthorize ${org})

if [ $? -eq 0 ]; then
    joinChannelAPI ${channelName} ${org} ${JWT}
    printResultAndSetExitCode "[${org}] joined to [${channelName}] channel "
else 
    exit 1
fi