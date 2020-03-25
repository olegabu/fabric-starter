#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org_=$2

printToLogAndToScreenCyan "Joining ${org_}.${DOMAIN} to the ${TEST_CHANNEL_NAME} channel using API..." | printToLogAndToScreen 
JWT=$(APIAuthorize ${org_})

if [ $? -eq 0 ]; then
    joinChannelAPI ${TEST_CHANNEL_NAME} ${org_} ${JWT}
    printResultAndSetExitCode " ${org_} joined to ${TEST_CHANNEL_NAME} channel "
else 
    exit 1
fi