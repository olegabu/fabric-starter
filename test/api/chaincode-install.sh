#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
#source "${BASEDIR}"/../libs/parse-common-params.sh $@

channelName=${1}
org=${2}

printToLogAndToScreenCyan "\nInstalling test chaincode in [${org}]"
JWT=$(APIAuthorize ${org})

if [ $? -eq 0 ]; then  
    installZippedChaincodeAPI ${channelName} ${org} ${JWT}
    printResultAndSetExitCode "Test chaincode installed in [${org}]"
else 
    exit 1
fi