#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org2_=$2

printToLogAndToScreenCyan "\nInstalling test chaincode in ${org2_}..."
JWT=$(APIAuthorize ${org2_})

if [ $? -eq 0 ]; then  
    installZippedChaincodeAPI ${TEST_CHANNEL_NAME} ${org2_} ${JWT}
    printResultAndSetExitCode "Test chaincode installed in ${org2_}"
else 
    exit 1
fi