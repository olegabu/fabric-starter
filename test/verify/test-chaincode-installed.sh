#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincodeName=${3:-$(getTestChaincodeName ${channelName})}

printToLogAndToScreenBlue "\nVerifing if the chaincode [${chaincodeName}] installed in [${org}]"

setCurrentActiveOrg ${org}
result=$(runCLIPeer ${org} listChaincodesInstalled ${channelName} ${org} \| grep -E "^${chaincodeName}$")

setExitCode [ "${result}" = "${chaincodeName}" ]
printResultAndSetExitCode "The test chaincode installed in [${org}]"
