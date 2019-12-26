#!/bin/bash

#source ${BASEDIR}/../lib/util/util.sh
#source ${BASEDIR}/../lib.sh
pwd;
cd ${FABRIC_DIR}; pwd; source ./lib/util/util.sh
cd ${FABRIC_DIR}; pwd; source ./lib.sh
#cd ${CURRENNT_DIR} 



TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME:-'testlocal'$RANDOM}
DEBUG=${DEBUG:-false}

ORG=${ORG:-org1}
ORG2=${ORG2:-org1}
#DOMAIN=${DOMAIN:-example.com}
PEER0_PORT=${PEER0_PORT:7051}

printInColor "1;36" "Adding <$ORG2> to the <$TEST_CHANNEL_NAME> channel..."
#Adding org to the $TEST_CHANNEL_NAME channel

#Adding second org to the $TEST_CHANNEL_NAME channel

(cd ${FABRIC_DIR} && ./channel-add-org.sh ${TEST_CHANNEL_NAME} ${ORG2} | tee -a ${FSTEST_LOG_FILE} > "${output}")

result=$(docker exec cli.${ORG}.${DOMAIN} /bin/bash -c \
    'source container-scripts/lib/container-lib.sh; \
       peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS -c '${TEST_CHANNEL_NAME}' $ORDERER_TLSCA_CERT_OPTS 2>/dev/null | \
       configtxlator  proto_decode --type common.Block | \
    jq .data.data[0].payload.data.config.channel_group.groups.Application.groups.'${ORG2}'.values.MSP.value.config.name' |
    sed -E -e 's/\"|\n|\r//g')

#
if [ "$result" = "$ORG2" ]; then
        printGreen "OK: <$result> has been added to the <$TEST_CHANNEL_NAME> channel."
        exit 0
else
    printError "ERROR: failed to add <$ORG2> to the <$TEST_CHANNEL_NAME> channel!"
    printError "See logs above.                                   "
    exit 1
fi

