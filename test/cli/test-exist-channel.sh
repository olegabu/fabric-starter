#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh



TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})

printInColor "1;36" "Verifing if the <$TEST_CHANNEL_NAME> channel exists in ${ORG}.${DOMAIN}..."

#store container stderr for debug in TMP_LOG_FILE, trap deletes it on exit
TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;

result=$(docker exec cli.${ORG}.${DOMAIN} /bin/bash -c \
       'source container-scripts/lib/container-lib.sh; \
        peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS \
       -c '${TEST_CHANNEL_NAME}' $ORDERER_TLSCA_CERT_OPTS | \
       configtxlator  proto_decode --type "common.Block"  | \
       jq .data.data[0].payload.data.last_update.payload.header.channel_header | \
       tee /dev/stderr | \
       jq .channel_id | \
       sed -E -e "s/\"|\n|\r//g"' 2>"${TMP_LOG_FILE}")

       cat "${TMP_LOG_FILE}" | printDbg
       printDbg "configtxlator output for .channel_id: $result";


if [ "${result}" = "${TEST_CHANNEL_NAME}" ]; then
    printGreen "\nOK: The channel <$TEST_CHANNEL_NAME> exists." | printDbg
    exit 0
else
    printError "\nERROR: Creating channel <$TEST_CHANNEL_NAME> failed!\n See ${FSTEST_LOG_FILE} for logs." | printDbg
    exit 1
fi


