#!/bin/bash
BASEDIR=$(dirname $0)
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}


source ${BASEDIR}/../libs.sh



TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}
ORG2=${2:-${ORG2}}
ORG=${ORG:-org1}
ORG2=${ORG2:-org1}


#FSTEST_LOG_FILE=${BASEDIR}
DEBUG=${DEBUG:-false}

printInColor "1;36" "Adding the <$ORG2> org to <$TEST_CHANNEL_NAME> channel ..."

DOMAIN=${DOMAIN:-example.com}
PEER0_PORT=${PEER0_PORT:7051}


#Adding org to the $TEST_CHANNEL_NAME channel


(cd ${FABRIC_DIR} && ./channel-add-org.sh ${TEST_CHANNEL_NAME} ${ORG2} 2>&1) | printDbg
channelCreateExitCode=$?



if [[ "$channelCreateExitCode" -eq 0 ]]; then
printGreen "\nOK: Channel <$TEST_CHANNEL_NAME> created successfully." 
    exit 0
else
printError "\nERROR: Creating channel <$TEST_CHANNEL_NAME> failed!\nSee ${FSTEST_LOG_FILE} for logs."
    exit 1
fi


