#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME:? Channel name is required.}}
ORG=${2:-$ORG1}

printLogScreenCyan "Creating ${TEST_CHANNEL_NAME} channel in ${ORG}.${DOMAIN} using API..." 

JWT=$(APIAuthorize ${ORG})

if [ $? -eq 0 ]; then  
    createChannelAPI ${TEST_CHANNEL_NAME} ${ORG} ${JWT}
fi