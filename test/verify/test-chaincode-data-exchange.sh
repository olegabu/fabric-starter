#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${BASEDIR}/fs_network_test.log"}}

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}

ORG=${ORG:-org1}
DOMAIN=${DOMAIN:-example.com}

CHAINCODE_PREFIX=${CHAINCODE_PREFIX:-reference}

ORG1=${ORG1:-org1}
ORG2=${ORG2:-org2}


printInColor "1;36" "Testing put/query operations with <${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}> chaincode to the <${TEST_CHANNEL_NAME}> channel..."


#put from $first_org
printInColor "1;36" "Invoke the ${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME} chaincode with 'put' function to the <$TEST_CHANNEL_NAME> on the <$ORG1> org with value <$TEST_CHANNEL_NAME>..."


(cd ${FABRIC_DIR} && PEER0_PORT=$(getPeer0Port ${ORG1} ${DOMAIN}) ORG=org1 ./chaincode-invoke.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME} '["put","'${TEST_CHANNEL_NAME}'","'${TEST_CHANNEL_NAME}'"]') | printDbg



printInColor "1;36" "5 seconds delay..."
sleep 5
#query from $second_org
printInColor "1;36" "Querying the <${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}> chaincode for the <$TEST_CHANNEL_NAME> key on the <$ORG2> org expecting value <$TEST_CHANNEL_NAME>..."

(cd ${FABRIC_DIR} &&  PEER0_PORT=$(getPeer0Port ${ORG2} ${DOMAIN}) ORG=org2 ./chaincode-query.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME} '["get","'${TEST_CHANNEL_NAME}'"]' 2>&1 | tee /tmp/${TEST_CHANNEL_NAME} )| printDbg

result=$(tail -1 /tmp/${TEST_CHANNEL_NAME} | sed -e 's/\n//g' -e 's/\r//g')
rm /tmp/${TEST_CHANNEL_NAME}

if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
    
    printGreen "OK: put <$TEST_CHANNEL_NAME>, got <$result> as expected."
    exit 0
else

    printError "ERROR: put <$TEST_CHANNEL_NAME>, got <$result>!"
    printError "See logs above."
    exit 1
fi

