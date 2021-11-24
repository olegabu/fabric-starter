#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincodeName=${3} #optional; "reference_channel"
lang=${4} #optional; "node"
path=${5} #optional; 

printToLogAndToScreenCyan "\nInstalling test chaincode in [${org}]"

setCurrentActiveOrg ${org}

printToLogAndToScreenCyan "\nCopying test chaincode to [${org}]"

copyTestChiancodeCLI ${channelName} ${org} ${chaincodeName} ${lang} ${path}

printToLogAndToScreenCyan "\nInstalling [$(getTestChaincodeName ${channelName})] chaincode in [${org}]"
installTestChiancodeCLI ${channelName} ${org} ${chaincodeName} ${lang}

printResultAndSetExitCode "Test chaincode installed in [${org}]"
