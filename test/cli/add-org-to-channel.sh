#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org2_=$3

printToLogAndToScreenCyan "\nAdd ${org2_} to the ${TEST_CHANNEL_NAME} channel..."

setCurrentActiveOrg ${ORG}

runInFabricDir ./channel-add-org.sh ${TEST_CHANNEL_NAME} ${org2_}

printResultAndSetExitCode "Organization ${org2_} added to ${TEST_CHANNEL_NAME} channel"