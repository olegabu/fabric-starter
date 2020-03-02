#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

printToLogAndToScreenCyan "\nJoining  ${ORG} to the ${TEST_CHANNEL_NAME} channel..."

setCurrentActiveOrg ${ORG}

runInFabricDir ./channel-join.sh ${TEST_CHANNEL_NAME} 

printResultAndSetExitCode "Organization ${ORG} has been joined to ${TEST_CHANNEL_NAME} channel"
