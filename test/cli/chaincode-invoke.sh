#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincodeName=${3}

printToLogAndToScreenCyan "\nInvoke test chaincode on the [$channelName] channel'"

setCurrentActiveOrg ${org}

runInFabricDir ./chaincode-invoke.sh ${channelName} ${chaincodeName} \''["put","'${channelName}'","'${channelName}_'"]'\'

printResultAndSetExitCode "Chaincode [${chaincode_name}] invoked sucsessfuly."


