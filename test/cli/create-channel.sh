#!/usr/bin/env bash

BASEDIR=$(dirname $0)
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}

source ${BASEDIR}/../libs.sh

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}

printInColor "1;36" "Creating the <$TEST_CHANNEL_NAME> channel for ${ORG}.${DOMAIN}..."

(cd ${FABRIC_DIR} && ./channel-create.sh ${TEST_CHANNEL_NAME} 2>&1) |printDbg
    channelCreateExitCode=$?



    if [[ "$channelCreateExitCode" -eq 0 ]]; then
    printGreen "\nOK: Channel <$TEST_CHANNEL_NAME> created successfully."
        exit 0
    else
    printError "\nERROR: Creating channel <$TEST_CHANNEL_NAME> failed!\nSee ${FSTEST_LOG_FILE} for logs."
        exit 1
    fi
    echo"\n\n"
