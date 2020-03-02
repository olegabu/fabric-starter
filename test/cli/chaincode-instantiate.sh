#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org2_=$2

printToLogAndToScreenCyan "\nInstantiate test chaincode in ${TEST_CHANNEL_NAME} in ${org2_}..."

setCurrentActiveOrg ${ORG}

instantiateTestChaincodeCLI ${TEST_CHANNEL_NAME} ${org2_}

printResultAndSetExitCode "Test chaincode instantiated in ${TEST_CHANNEL_NAME} by ${org2_}"


return 0




















[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${BASEDIR}/fs_network_test.log"}}


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
