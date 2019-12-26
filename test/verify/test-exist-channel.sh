#!/bin/bash

source ./libs.sh

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})

printInColor "1;36" "Verifing if the <$TEST_CHANNEL_NAME> channel exists in ${ORG}.${DOMAIN}..."


result=`docker exec cli.${ORG}.${DOMAIN} /bin/bash -c \
       'source container-scripts/lib/container-lib.sh; \
       peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS \
       -c '${TEST_CHANNEL_NAME}' $ORDERER_TLSCA_CERT_OPTS 2>/dev/stderr | \
       configtxlator  proto_decode --type "common.Block" | \
       jq .data.data[0].payload.data.last_update.payload.header.channel_header.channel_id' | \
       sed -E -e 's/\"|\n|\r//g'`

#the $result should contain the exact channel name provided

#echo ${result}

if [ "${result}" = "${TEST_CHANNEL_NAME}" ]; then
    printGreen "\nOK: The channel <$TEST_CHANNEL_NAME> exists."
    exit 0
else
    printError "\nERROR: Creating channel <$TEST_CHANNEL_NAME> failed!\n See ${FSTEST_LOG_FILE} for logs."
    exit 1
fi
