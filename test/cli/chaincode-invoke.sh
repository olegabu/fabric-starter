#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=${2}
chaincode_name=${3}

printToLogAndToScreenCyan "\nInvoke test chaincode on the [$TEST_CHANNEL_NAME] channel'"

setCurrentActiveOrg ${org}

#echo runInFabricDir ./chaincode-invoke.sh ${TEST_CHANNEL_NAME} ${chaincode_name} '["\"put\"","\"'${TEST_CHANNEL_NAME}'\"","\"'${TEST_CHANNEL_NAME}'\""]'

runInFabricDir ./chaincode-invoke.sh ${TEST_CHANNEL_NAME} ${chaincode_name} \''["put","'${TEST_CHANNEL_NAME}'","'${TEST_CHANNEL_NAME}_'"]'\'


printResultAndSetExitCode "Chaincode [${chaincode_name}] invoked sucsessfuly."


