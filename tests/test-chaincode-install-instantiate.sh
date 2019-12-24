#!/bin/bash

source ${BASEDIR}/../lib/util/util.sh
source ${BASEDIR}/../lib.sh

#DEBUG=${DEBUG:-false}

printInColor "1;36" "$ORG (Port:$PEER0_PORT) Installing and instantiating the <$CHAINCODE_NAME> chaincode to the <${TEST_CHANNEL_NAME}> channel..."

#echo "(cd ${BASEDIR}/.. && PEER0_PORT=$PEER0_PORT ORG=$ORG ./chaincode-instantiate.sh $TEST_CHANNEL_NAME $CHAINCODE_NAME | tee -a $FSTEST_LOG_FILE > "${output}")"
(cd ${BASEDIR}/.. && PEER0_PORT=${PEER0_PORT} ORG=${ORG} ./chaincode-instantiate.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_NAME} | tee -a ${FSTEST_LOG_FILE} > "${output}")

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
