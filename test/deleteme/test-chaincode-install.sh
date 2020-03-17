#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${TEST_LAUNCH_DIR}/fs_network_test.log"}}

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}

ORG=${ORG:-org1}
DOMAIN=${DOMAIN:-example.com}

CHAINCODE_PREFIX=${CHAINCODE_PREFIX:-reference}


printInColor "1;36" "$ORG (Port:$PEER0_PORT) Verifing if the <${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}> chaincode installed on the cli.${ORG}.${DOMAIN} machine"

TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;


result=$(docker exec cli.${ORG}.${DOMAIN} /bin/bash -c \
    'source container-scripts/lib/container-lib.sh; \
    peer chaincode list --installed -C '${TEST_CHANNEL_NAME}' -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS' \
|tail -n+2 | cut -d ':' -f 2 | cut -d ',' -f 1 | sed -Ee 's/ |\n|\r//g'| grep "${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}" 2>"${TMP_LOG_FILE}")

cat "${TMP_LOG_FILE}" | printDbg
printDbg "peer chaincode list --installed output for .channel_id: $result";



if [ "$result" = "${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}" ]; then
    
    printGreen "OK: $ORG reports the <${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}> chaincode is successfully instantiated on the <$TEST_CHANNEL_NAME> channel."
    exit 0
else
    
    printError "ERROR: $ORG reports the <${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}> chaincode failed to instantiate on the <$TEST_CHANNEL_NAME> channel."
    printError "See logs above."
    exit 1
fi
