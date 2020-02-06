#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/../libs.sh


: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${BASEDIR}/fs_network_test.log"}}

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}

ORG=${ORG:-org1}
DOMAIN=${DOMAIN:-example.com} 

CHAINCODE_PREFIX=${CHAINCODE_PREFIX:-reference}


printInColor "1;36" "$ORG (Port:$PEER0_PORT) Installing the <${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}> chaincode on the cli.${ORG}.${DOMAIN} machine"


docker exec -i cli.${ORG}.${DOMAIN} sh -c "mkdir -p /opt/chaincode/node/${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME} ; cp -R /opt/chaincode/node/reference/* \
                                           /opt/chaincode/node/${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}"  2>&1 | printDbg
docker exec -i cli.${ORG}.${DOMAIN} sh -c "./container-scripts/network/chaincode-install.sh ${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}" 2>&1 | printDbg

exit


#echo "(cd ${BASEDIR}/.. && PEER0_PORT=$PEER0_PORT ORG=$ORG ./chaincode-instantiate.sh $TEST_CHANNEL_NAME $CHAINCODE_NAME | tee -a $FSTEST_LOG_FILE > "${output}")"
(cd ${FABRIC_DIR} && PEER0_PORT=${PEER0_PORT} ORG=${ORG} ./chaincode-instantiate.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_NAME} | tee -a ${FSTEST_LOG_FILE} > "${output}")

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
