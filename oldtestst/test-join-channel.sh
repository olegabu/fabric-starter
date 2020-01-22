#!/bin/bash

source ${BASEDIR}/../lib/util/util.sh
source ${BASEDIR}/../lib.sh

#TEST_CHANNEL_NAME='testlocal'$RANDOM
#CHAINCODE_NAME=${CHAINCODE_NAME:-reference}
#DEBUG=${DEBUG:-false}
#ORG=${ORG:-org1}
#first_org=${1:-org1}
#second_org=${2:-org2}

#DOMAIN=${DOMAIN:-example.com}
#PEER0_PORT=${PEER0_PORT:7051}

printInColor "1;36" "Joining the <$ORG> to the <${TEST_CHANNEL_NAME}> channel..."

    export PEER0_PORT=${PEER0_PORT} 
 #   echo "PEER0_PORT=$PEER0_PORT ORG=$ORG ./channel-join.sh ${TEST_CHANNEL_NAME} 2>&1 >$output" 
    
    (cd ${BASEDIR}/.. && ORG=${ORG} ./channel-join.sh ${TEST_CHANNEL_NAME} | tee -a ${FSTEST_LOG_FILE} > "${output}")
    
    #current_peer0_port=$((current_peer0_port + 1000))
    
    result=$(docker exec cli.${ORG}.${DOMAIN} /bin/bash -c \
        'source container-scripts/lib/container-lib.sh; \
        peer channel list -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS 2>/dev/null |\
    grep -E "^'${TEST_CHANNEL_NAME}'$"')
    
    if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
        printGreen "OK: <$ORG> successfully joined the <$TEST_CHANNEL_NAME> channel."
        exit 0
    else
        printError "ERROR: <$ORG> failed to join the <$TEST_CHANNEL_NAME> channel!"
        printError "See logs above.                                   "
        exit 1
    fi
