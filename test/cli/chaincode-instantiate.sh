#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincodeName=${3:-$(getTestChaincodeName ${channelName})}

printToLogAndToScreenCyan "\nInstantiate test chaincode in [${channelName}] by [${org}]"

setCurrentActiveOrg ${org}
result=$(runCLIPeer ${org} ./container-scripts/network/chaincode-instantiate.sh ${channelName} ${chaincodeName} 2>&1)
exit_code=$?

set +f
IFS=
printDbg ${result}
set -f

setExitCode [ "${exit_code}" = "0" ]
printResultAndSetExitCode "[${chaincodeName}] chaincode instantiated in [${channelName}] by [${org}]"
