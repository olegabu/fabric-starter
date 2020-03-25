#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org2_=${2}


printToLogAndToScreenBlue "\nVerifing if the test chaincode installed in ${org2_} org..."

setCurrentActiveOrg ${ORG}

verifyChiancodeInstalled "${TEST_CHANNEL_NAME}" "${org2_}"

printResultAndSetExitCode "The test chaincode installed in ${org2_}"