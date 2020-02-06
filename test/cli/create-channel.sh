#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs.sh
source "${BASEDIR}"/../parse-common-params.sh $@

printLogScreenCyan "Creating the <$TEST_CHANNEL_NAME> channel for ${ORG}.${DOMAIN}..."

runInFabricDir ./channel-create.sh ${TEST_CHANNEL_NAME} 

printResultAndSetExitCode "Channel <$TEST_CHANNEL_NAME> creation run sucsessfuly."
