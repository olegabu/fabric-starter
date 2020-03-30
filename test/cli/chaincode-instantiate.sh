#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=${2}

printToLogAndToScreenCyan "\nInstantiate test chaincode in ${TEST_CHANNEL_NAME} in ${org}..."

setCurrentActiveOrg ${org}

instantiateTestChaincodeCLI ${TEST_CHANNEL_NAME} ${org}

printResultAndSetExitCode "Test chaincode instantiated in ${TEST_CHANNEL_NAME} by ${org}"


