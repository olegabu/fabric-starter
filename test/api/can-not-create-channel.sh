#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
#source "${BASEDIR}"/../libs/parse-common-params.sh $@

channelName=${1}
org=${2}

printToLogAndToScreenCyan "Creating [${channelName}] channel in [${org}.${DOMAIN}] using API"
JWT=$(APIAuthorize ${org})

if [ $? -eq 0 ]; then  
    ! createChannelAPI ${channelName} ${org} ${JWT}
    printResultAndSetExitCode "Channel [${channelName}] can not be created."
else 
    exit 1
fi