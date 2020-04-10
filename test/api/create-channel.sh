#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=${2}

printToLogAndToScreenCyan "Creating [${TEST_CHANNEL_NAME}] channel in [${org}.${DOMAIN}] using API..." 
JWT=$(APIAuthorize ${org})
if [ $? -eq 0 ]; then  
    createChannelAPI ${TEST_CHANNEL_NAME} ${org} ${JWT}
    printResultAndSetExitCode "Channel [$TEST_CHANNEL_NAME] creation run sucsessfuly."
else 
    exit 1
fi