#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}
ORG=${2:-$ORG1}

printCyan "Creating ${TEST_CHANNEL_NAME} channel in ${ORG}.${DOMAIN} using API..." | printLogScreen

JWT=$(APIAuthorize ${ORG})
if [[ ! $? -eq 0 ]]; then exit 1; fi 

createChannelAPI ${TEST_CHANNEL_NAME} ${ORG} ${JWT}