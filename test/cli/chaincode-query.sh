#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincodeName=${3}

printToLogAndToScreenCyan "\nQuery test chaincode on the [$channelName] channel'"

setCurrentActiveOrg ${org}

runInFabricDir ./chaincode-query.sh ${channelName} ${chaincodeName} \''["range","'${channelName}'"]'\' 2>&1 1>/tmp/11111${channelName}

printResultAndSetExitCode "Chaincode [${chaincode_name}] query run sucsessfuly."
