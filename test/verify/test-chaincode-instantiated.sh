#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=${2}


printToLogAndToScreenBlue "\nVerifing if the test chaincode instantiated in channel [${TEST_CHANNEL_NAME}] channel by [${org}]"

setCurrentActiveOrg ${org}

verifyChiancodeInstantiated "${TEST_CHANNEL_NAME}" "${org}"

printResultAndSetExitCode "The test chaincode installed in [${TEST_CHANNEL_NAME}] channel by [${org}] org"
