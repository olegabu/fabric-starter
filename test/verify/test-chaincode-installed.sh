#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
#domain=${3:-${DOMAIN}}
chaincode=${3} #optional

printToLogAndToScreenBlue "\nVerifing if the test chaincode installed in [${org}]"

setCurrentActiveOrg ${org}
verifyChiancodeInstalled "${channelName}" "${org}" "${chaincode}"

printResultAndSetExitCode "The test chaincode installed in [${org}]"
