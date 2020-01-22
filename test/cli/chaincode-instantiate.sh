#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh

: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}


ORG=${ORG:-org1}
export ORG=${ORG:-org1}
CHAINCODE_PREFIX=${CHAINCODE_PREFIX:-reference}
TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})

printInColor "1;36" "$ORG (Port:$PEER0_PORT) Instantiating the <${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}> chaincode to the <${TEST_CHANNEL_NAME}> channel..."
(cd ${FABRIC_DIR} && PEER0_PORT=${PEER_PORT} ORG=${ORG}           ./chaincode-instantiate.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME} 2>&1) | printDbg

exit


#Wait for the chaincode to instantiate
sleep 5

    result=$(docker exec cli.${ORG}.${DOMAIN} /bin/bash -c \
        'source container-scripts/lib/container-lib.sh; \
        peer chaincode list --instantiated -C '${TEST_CHANNEL_NAME}' -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS 2>/dev/null' |
        tail -n+2 | cut -d ':' -f 2 | cut -d ',' -f 1 | sed -Ee 's/ |\n|\r//g')

    if [ "$result" = "$CHAINCODE_NAME" ]; then
        
        printGreen "OK: $ORG reports the <$CHAINCODE_NAME> chaincode is successfully instantiated on the <$TEST_CHANNEL_NAME> channel."
        exit 0
    else
        
        printError "ERROR: $ORG reports the <$CHAINCODE_NAME> chaincode failed to instantiate on the <$TEST_CHANNEL_NAME> channel."
        printError "See logs above."
        exit 1
    fi
