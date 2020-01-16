#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh



TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})

ORG=${ORG:-org1}
DOMAIN=${DOMAIN:-example.com}



printInColor "1;36" "Verifing if the <$ORG> has joined the <$TEST_CHANNEL_NAME> channel..."

#store container stderr for debug in TMP_LOG_FILE, trap deletes it on exit
TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;

export PEER0_PORT=${PEER0_PORT} 

result=$(docker exec cli.${ORG}.${DOMAIN} /bin/bash -c \
	'source container-scripts/lib/container-lib.sh; \
        peer channel list -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS |\
	grep -E "^'${TEST_CHANNEL_NAME}'$"' 2>"${TMP_LOG_FILE}")


       cat "${TMP_LOG_FILE}" | printDbg

       printDbg "configtxlator output for .channel_id: $result";


    if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
        printGreen "OK: <$ORG> successfully joined the <$TEST_CHANNEL_NAME> channel."
        exit 0
    else
        printError "ERROR: <$ORG> failed to join the <$TEST_CHANNEL_NAME> channel!"
        printError "See logs above.                                   "
        exit 1
    fi


