#!/bin/bash

source ${BASEDIR}/../lib/util/util.sh
source ${BASEDIR}/../lib.sh

#DEBUG=${DEBUG:-false}
#ORG=${ORG:-org1}
#DOMAIN=${DOMAIN:-example.com}
#PEER0_PORT=${PEER0_PORT:7051}


printInColor "1;36" "Creating the <$TEST_CHANNEL_NAME> channel..."

#Creating the $TEST_CHANNEL_NAME channel

 (cd ${BASEDIR}/.. && ./channel-create.sh ${TEST_CHANNEL_NAME} | tee -a ${FSTEST_LOG_FILE} > "${output}")

#Check if the channel has been created

result=`docker exec cli.${ORG}.${DOMAIN} /bin/bash -c \
       'source container-scripts/lib/container-lib.sh; \
       peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS \
       -c '${TEST_CHANNEL_NAME}' $ORDERER_TLSCA_CERT_OPTS 2>/dev/null  | \
       configtxlator  proto_decode --type "common.Block" | \
       jq .data.data[0].payload.data.last_update.payload.header.channel_header.channel_id' | \
       sed -E -e 's/\"|\n|\r//g'`

#the $result should contain the exact channel name created on the previous step

#echo $result

if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
    printGreen "OK: Test channel <$TEST_CHANNEL_NAME> created successfully."
    exit 0
else
    printError "ERROR: Creating channel <$TEST_CHANNEL_NAME> failed!"
    printError "See logs above.                                   "
    exit 1
fi
