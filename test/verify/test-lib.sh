#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh


: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}

ORG=${ORG:-org1}
DOMAIN=${DOMAIN:-example.com}

CHAINCODE_PREFIX=${CHAINCODE_PREFIX:-reference}

DEBUG=${DEBUG:-false}
ORG=${ORG:-org1}
ORG1=${ORG1:-org1}
ORG2=${ORG2:-org2}

#CHAINCODE_NAME=reference${TEST_CHANNEL_NAME}



echo $(getPeer0Port org2 example.com)
echo $(getAPIPort org2 example.com)




exit




printInColor "1;36" "Testing put/query operations with <> chaincode to the <${TEST_CHANNEL_NAME}> channel..."


#put from $first_org
printInColor "1;36" "Invoke the ${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME} chaincode with 'put' function to the <$TEST_CHANNEL_NAME> on the <$ORG1> org with value <$TEST_CHANNEL_NAME>..."


(cd ${FABRIC_DIR} && PEER0_PORT=7051 ORG=org1 ./chaincode-invoke.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME} '["put","'${TEST_CHANNEL_NAME}'","'${TEST_CHANNEL_NAME}'"]'| tee -a ${FSTEST_LOG_FILE} > "${output}")



printInColor "1;36" "5 seconds delay..."
sleep 5
#query from $second_org
printInColor "1;36" "Querying the <${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}> chaincode for the <$TEST_CHANNEL_NAME> key on the <$ORG2> org expecting value <$TEST_CHANNEL_NAME>..."

(cd ${FABRIC_DIR} &&  PEER0_PORT=8051 ORG=org2 ./chaincode-query.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME} '["get","'${TEST_CHANNEL_NAME}'"]' 2>&1 | tee /tmp/${TEST_CHANNEL_NAME} )| printDbg

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

