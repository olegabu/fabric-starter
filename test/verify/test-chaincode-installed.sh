#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincodeName=${3:-$(getTestChaincodeName ${channelName})}

printToLogAndToScreenBlue "\nVerifing if the chaincode [${chaincodeName}] installed in [${org}]"

setCurrentActiveOrg ${org}
#verifyChiancodeInstalled "${channelName}" "${org}" "${chaincode}"

result=$(runCLIPeer ${org} listChaincodesInstalled ${channelName} ${org})
set -f
IFS=
printDbg "Result: ${result}"
result=$(echo $result | tr -d "\r" | grep -E "^${chaincodeName}$")
set +f

setExitCode [ "${result}" = "${chaincodeName}" ]
printResultAndSetExitCode "The test chaincode installed in [${org}]"
