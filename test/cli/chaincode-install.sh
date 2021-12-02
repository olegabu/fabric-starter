#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
domain=${3:-${DOMAIN}}
chaincodeName=${4} #optional; "reference_channel"
lang=${5} #optional; "node"
path=${6} #optional;

printToLogAndToScreenCyan "\nInstalling test chaincode in [${org}.${domain}]"

setCurrentActiveOrg ${org}

printToLogAndToScreenCyan "\nCopying test chaincode to [${org}]"

copyTestChiancodeCLI ${channelName} ${org} ${domain} ${chaincodeName} ${lang} ${path}

printToLogAndToScreenCyan "\nInstalling [$(getTestChaincodeName ${channelName})] chaincode in [${org}]"
installTestChiancodeCLI ${channelName} ${org} ${domain} ${chaincodeName} ${lang}

printResultAndSetExitCode "Test chaincode installed in [${org}.${domain}]"
