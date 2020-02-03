#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh
source ${BASEDIR}/../parse-common-params.sh $@
#export DEBUG=false

printLogScreenCyan "Verifing if the <$TEST_CHANNEL_NAME> channel exists in ${ORG}.${DOMAIN}..."

verifyChannelExists "${TEST_CHANNEL_NAME}" "${ORG}" 



# function queryPeer() {
#     local channel=${1}
#     local org=${2}
#     local query=${3}
#     local subquery${4:-.}
# local result=$(docker exec cli.${org}.${DOMAIN} /bin/bash -c \
#         'source container-scripts/lib/container-lib.sh; \
#          peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS -c '${channel}' $ORDERER_TLSCA_CERT_OPTS | \
#          configtxlator  proto_decode --type "common.Block"  | \
#         jq $query | \
#         tee /dev/stderr | \
#         jq $subquery')   
#     echo $result    


#echo $(queryPeer ${TEST_CHANNEL_NAME} ${ORG} '.data.data[0].payload.header.channel_header' '.channel_id')
#exit

printResultAndSetExitCode "The channel <$TEST_CHANNEL_NAME> exists and visible to ${ORG}"
