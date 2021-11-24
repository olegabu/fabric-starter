#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincodeName=${3} #optional

printToLogAndToScreenCyan "\nInstantiate test chaincode in [${channelName}] by [${org}]"

setCurrentActiveOrg ${org}
instantiateTestChaincodeCLI ${channelName} ${org} ${chaincodeName}

printResultAndSetExitCode "Test chaincode instantiated in [${channelName}] by [${org}]"
