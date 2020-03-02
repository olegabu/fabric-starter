#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs.sh
source "${BASEDIR}"/../parse-common-params.sh $@

org2_=$2

printToLogAndToScreenCyan "\nInstalling test chaincode in ${org2_}..."

setCurrentActiveOrg ${ORG}

copyTestChiancodeCLI ${TEST_CHANNEL_NAME} ${org2_}

if [ $? -eq 0 ]; then  
    installTestChiancodeCLI ${TEST_CHANNEL_NAME} ${org2_}

    printResultAndSetExitCode "Test chaincode installed in ${org2_}"
else 
    exit 1
fi