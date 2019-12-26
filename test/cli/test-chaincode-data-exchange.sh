#!/bin/bash

#source ${BASEDIR}/../lib/util/util.sh
#source ${BASEDIR}/../lib.sh

cd ${FABRIC_DIR}; source ./lib/util/util.sh
cd ${FABRIC_DIR}; source ./lib.sh


DEBUG=${DEBUG:-false}
ORG=${ORG:-org1}
ORG1=${ORG1:-org1}
ORG2=${ORG2:-org2}

printInColor "1;36" "Testing put/query operations with <$CHAINCODE_NAME> chaincode to the <${TEST_CHANNEL_NAME}> channel..."


#put from $first_org
printInColor "1;36" "Invoke the <$CHAINCODE_NAME> chaincode with 'put' function to the <$TEST_CHANNEL_NAME> on the <$ORG1> org with value <$TEST_CHANNEL_NAME>..."


(cd ${FABRIC_DIR} && PEER0_PORT=7051 ORG=org1 ./chaincode-invoke.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_NAME} '["put","'${TEST_CHANNEL_NAME}'","'${TEST_CHANNEL_NAME}'"]'| tee -a ${FSTEST_LOG_FILE} > "${output}")



printInColor "1;36" "5 seconds delay..."
sleep 5
#query from $second_org
printInColor "1;36" "Querying the <$CHAINCODE_NAME> for the <$TEST_CHANNEL_NAME> key on the <$ORG2> org expecting value <$TEST_CHANNEL_NAME>..."

(cd ${FABRIC_DIR} &&  PEER0_PORT=8051 ORG=org2 ./chaincode-query.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_NAME} '["get","'${TEST_CHANNEL_NAME}'"]' 2>&1 | tee /tmp/${TEST_CHANNEL_NAME} | tee -a ${FSTEST_LOG_FILE} > "${output}")

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

