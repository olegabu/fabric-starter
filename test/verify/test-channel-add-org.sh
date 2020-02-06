#!/bin/bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/../libs.sh



TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})
ORG2=${2:-${ORG2}}
ORG2=${ORG2:-org2}
ORG=${ORG:-org1}

printInColor "1;36" "Verifing if the <$ORG2> added to ${TEST_CHANNEL_NAME} ..."

#store container stderr for debug in TMP_LOG_FILE, trap deletes it on exit
TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;


result=$(docker exec cli.org1.${DOMAIN} /bin/bash -c \
       'source container-scripts/lib/container-lib.sh; \
        peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS \
        -c '${TEST_CHANNEL_NAME}' $ORDERER_TLSCA_CERT_OPTS | \
        configtxlator proto_decode --type common.Block | \
        jq .data.data[0].payload.data.config.channel_group.groups.Application.groups.'${ORG2}'.values.MSP.value | \
        tee /dev/stderr | \
        jq  .config.name | \
        sed -E -e "s/\"|\n|\r//g"' 2>"${TMP_LOG_FILE}")

       cat "${TMP_LOG_FILE}" | printDbg
       printDbg "configtxlator output for channel_id: $result";


if [ "${result}" = "${ORG2}" ]; then
    printGreen "\nOK: <$ORG2> is in the channel <$TEST_CHANNEL_NAME>." | sed -e "s/\n//g" | printLogScreen
    exit 0
else
    printError "\nERROR: <$ORG2> org is not in the <$TEST_CHANNEL_NAME> channel!\n See ${FSTEST_LOG_FILE} for logs." | sed -e "s/\n//g"| printLogScreen
    exit 1
fi


