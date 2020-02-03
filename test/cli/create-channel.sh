#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh
source ${BASEDIR}/../parse-common-params.sh $@

printLogScreenCyan "Creating the <$TEST_CHANNEL_NAME> channel for ${ORG}.${DOMAIN}..."

runInFabricDir ./channel-create.sh ${TEST_CHANNEL_NAME} 

printResultAndSetExitCode "Channel <$TEST_CHANNEL_NAME> creation run sucsessfuly."
