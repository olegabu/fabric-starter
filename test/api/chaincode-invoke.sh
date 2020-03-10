#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org2_=${2}
chaincode_name=${3}

printToLogAndToScreenCyan "\nInvoke test chaincode on the <$TEST_CHANNEL_NAME> channel'"

JWT=$(APIAuthorize ${org2_})

if [ $? -eq 0 ]; then  
    invokeTestChaincodeAPI ${TEST_CHANNEL_NAME} ${org2_} {$chaincode_name} ${JWT}

    printResultAndSetExitCode "Chaincode ${chaincode_name} invoked sucsessfuly."

else 
    exit 1
fi


