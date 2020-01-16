#!/usr/bin/env bash

BASEDIR=$(dirname $0)
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}

source ${BASEDIR}/../libs.sh

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}

ORG2=${2:-${ORG2}}
ORG=${ORG:-org1}
ORG2=${ORG2:-org1}


printInColor "1;36" "Joining the <$ORG2> to the <${TEST_CHANNEL_NAME}> channel..."

    export PEER0_PORT=${PEER0_PORT} 
    
    (cd ${FABRIC_DIR} && ORG=${ORG} ./channel-join.sh ${TEST_CHANNEL_NAME} 2>&1)| printDbg
    channelCreateExitCode=$?



    if [[ "$channelCreateExitCode" -eq 0 ]]; then
    printGreen "\nOK: <$ORG2> joined the <$TEST_CHANNEL_NAME> channel successfully."
        exit 0
    else
    printError "\nERROR: Loining <$ORG2> to channel <$TEST_CHANNEL_NAME> failed!\nSee ${FSTEST_LOG_FILE} for logs."
        exit 1
    fi
    echo"\n\n"
