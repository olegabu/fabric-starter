#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}

printToLogAndToScreenCyan "\nInstantiate test chaincode in [${channelName}] by [${org}]"

setCurrentActiveOrg ${org}

instantiateTestChaincodeCLI ${channelName} ${org}

printResultAndSetExitCode "Test chaincode instantiated in [${channelName}] by [${org}]"


