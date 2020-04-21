#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}


printToLogAndToScreenBlue "\nVerifing if the test chaincode instantiated in channel [${channelName}] channel by [${org}]"

setCurrentActiveOrg ${org}

verifyChiancodeInstantiated "${channelName}" "${org}"

printResultAndSetExitCode "The test chaincode installed in [${channelName}] channel by [${org}] org"
