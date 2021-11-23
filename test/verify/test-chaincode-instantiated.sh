#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincode=${3} #optional

printToLogAndToScreenBlue "\nVerifing if the test chaincode instantiated in channel [${channelName}] channel by [${org}]"

setCurrentActiveOrg ${org}
verifyChiancodeInstantiated "${channelName}" "${org}" "${chaincode}"

printResultAndSetExitCode "The test chaincode instantiated in [${channelName}] channel by [${org}] org"
