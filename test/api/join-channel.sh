#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=${2}

printToLogAndToScreenCyan "Joining ${org}.${DOMAIN} to the ${TEST_CHANNEL_NAME} channel using API..." | printToLogAndToScreen 
JWT=$(APIAuthorize ${org})

if [ $? -eq 0 ]; then
    joinChannelAPI ${TEST_CHANNEL_NAME} ${org} ${JWT}
    printResultAndSetExitCode " ${org} joined to ${TEST_CHANNEL_NAME} channel "
else 
    exit 1
fi