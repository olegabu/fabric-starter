#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=${2}
chaincode_name=${3}

printToLogAndToScreenCyan "\nQuery test chaincode on the [$TEST_CHANNEL_NAME] channel'"

setCurrentActiveOrg ${org}

runInFabricDir ./chaincode-query.sh ${TEST_CHANNEL_NAME} ${chaincode_name} \''["range","'${TEST_CHANNEL_NAME}'"]'\' 2>&1 1>/tmp/11111${TEST_CHANNEL_NAME}

printResultAndSetExitCode "Chaincode [${chaincode_name}] query run sucsessfuly."
