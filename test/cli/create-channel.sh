#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME:? Channel name is required.}}
ORG=${2:-$ORG1}

printLogScreenCyan "Creating the <$TEST_CHANNEL_NAME> channel for ${ORG}.${DOMAIN}..."

(cd ${FABRIC_DIR} && ./channel-create.sh ${TEST_CHANNEL_NAME} 2>&1) | printDbg

printAndCompareResults \
"\nOK: Channel <$TEST_CHANNEL_NAME> creation run sucsessfuly." \
"\nERROR: Creating channel <$TEST_CHANNEL_NAME> failed!\nSee ${FSTEST_LOG_FILE} for logs."