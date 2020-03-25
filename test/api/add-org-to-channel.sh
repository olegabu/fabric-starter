#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org2_=$3

printToLogAndToScreenCyan  "Add ${org2_} to the ${TEST_CHANNEL_NAME} channel using API..." | printToLogAndToScreen
JWT=$(APIAuthorize ${ORG})


if [ $? -eq 0 ]; then  
    addOrgToTheChannel ${TEST_CHANNEL_NAME} ${ORG} ${JWT} ${org2_}
    printResultAndSetExitCode "Organization ${org2_} added to ${TEST_CHANNEL_NAME} channel"
else 
    exit 1
fi

