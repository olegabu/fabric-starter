#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh
source ${BASEDIR}/../parse-common-params.sh $@

printLogScreenCyan "Creating ${TEST_CHANNEL_NAME} channel in ${ORG}.${DOMAIN} using API..." 

JWT=$(APIAuthorize ${ORG})

if [ $? -eq 0 ]; then  
    createChannelAPI ${TEST_CHANNEL_NAME} ${ORG} ${JWT}
    printResultAndSetExitCode "Channel <$TEST_CHANNEL_NAME> creation run sucsessfuly."
else 
    exit 1
fi