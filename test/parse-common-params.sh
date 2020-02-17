#!/usr/bin/env bash

#export DOMAIN=${1:-${DOMAIN:-example.com}}
export TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME:? Channel name is required.}}
#export DOMAIN=${1:-${DOMAIN:? Domain is required.}}

 #active org
 export ORG=${2:-${ORG1:-org1}}

 #export ORG1=${ORG}
 #export ORG2=${3:-${ORG2:-org2}}

export PEER_NAME=${PEER_NAME:-peer0}
export API_NAME=${API_NAME:-api}