#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=${2}

printToLogAndToScreenCyan "\nInstalling test chaincode in [${org}]"

setCurrentActiveOrg ${org}

printToLogAndToScreenCyan "\nCopying test chaincode to [${org}]"

copyTestChiancodeCLI ${TEST_CHANNEL_NAME} ${org}

#if [ $? -eq 0 ]; then  

    printToLogAndToScreenCyan "\nInstalling [${TEST_CHANNEL_NAME}] chaincode in [${org}]"

    installTestChiancodeCLI ${TEST_CHANNEL_NAME} ${org}

    printResultAndSetExitCode "Test chaincode installed in [${org}]"
#else 
#    exit 1
#fi