#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}


printToLogAndToScreenBlue "\nVerifing if the test chaincode installed in [${org}]"

pushd ${FABRIC_DIR} >/dev/null
setCurrentActiveOrg ${org}
verifyChiancodeInstalled "${channelName}" "${org}"
popd >/dev/null

printResultAndSetExitCode "The test chaincode installed in [${org}]"
