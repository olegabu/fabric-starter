#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
#source "${BASEDIR}"/../libs/parse-common-params.sh $@

channelName=${1}
org=${2}
orgAdd=${3}

printToLogAndToScreenCyan  "Add [${orgAdd}] to the [${channelName}] channel using API" | printToLogAndToScreen
JWT=$(APIAuthorize ${org})


if [ $? -eq 0 ]; then  
    addOrgToChannelAPI ${TEST_CHANNEL_NAME} ${org} ${JWT} ${orgAdd}
    printResultAndSetExitCode "Organization [${orgAdd}] added to [${channelName}] channel"
else 
    exit 1
fi

