#!/usr/bin/env bash

source ./libs.sh



TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})

printInColor "1;36" "Creating the <$TEST_CHANNEL_NAME> channel for ${ORG}.${DOMAIN}..."


(cd ${FABRIC_DIR}; ./channel-create.sh ${TEST_CHANNEL_NAME} | tee -a ${FSTEST_LOG_FILE} > "${output}"; exit ${PIPESTATUS[0]}) 

channelCreateExitCode=$?

if [[ "$channelCreateExitCode" -eq 0 ]]; then
    printGreen "\nOK: Channel <$TEST_CHANNEL_NAME> created successfully."
    exit 0
else
    printError "\nERROR: Creating channel <$TEST_CHANNEL_NAME> failed!\nSee ${FSTEST_LOG_FILE} for logs."
    exit 1
fi

