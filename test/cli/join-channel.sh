#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs.sh
source "${BASEDIR}"/../parse-common-params.sh $@

printToLogAndToScreenCyan "\nJoining  ${ORG} to the ${TEST_CHANNEL_NAME} channel..."

setCurrentActiveOrg ${ORG}

#echo "ORG: $ORG PEER0_PORT: $PEER0_PORT"

runInFabricDir ./channel-join.sh ${TEST_CHANNEL_NAME} 

printResultAndSetExitCode "Organization ${ORG} has been joined to ${TEST_CHANNEL_NAME} channel"
