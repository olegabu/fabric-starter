#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=${2}

printToLogAndToScreenCyan "\nJoining [${org}] to the [${TEST_CHANNEL_NAME}] channel..."

setCurrentActiveOrg ${org}

runInFabricDir ./channel-join.sh ${TEST_CHANNEL_NAME} 

printResultAndSetExitCode "Organization [${org}] joined to [${TEST_CHANNEL_NAME}] channel"
