#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org2_=$2

printToLogAndToScreenCyan "\nInstantiate test chaincode in ${TEST_CHANNEL_NAME} in ${org2_}..."

setCurrentActiveOrg ${ORG}

instantiateTestChaincodeCLI ${TEST_CHANNEL_NAME} ${org2_}

printResultAndSetExitCode "Test chaincode instantiated in ${TEST_CHANNEL_NAME} by ${org2_}"


