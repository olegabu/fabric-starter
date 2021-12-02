#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
domain=${3:-${DOMAIN}}
chaincode=${4} #optional

printToLogAndToScreenBlue "\nVerifing if the test chaincode instantiated in channel [${channelName}] channel by [${org}.${domain}]"

setCurrentActiveOrg ${org}
verifyChiancodeInstantiated "${channelName}" "${org}" ${domain} "${chaincode}"

printResultAndSetExitCode "The test chaincode instantiated in [${channelName}] channel by [${org}.${domain}] org"
