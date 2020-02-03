#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh
source ${BASEDIR}/../parse-common-params.sh $@

printLogScreenCyan "Creating the <$TEST_CHANNEL_NAME> channel for ${ORG}.${DOMAIN}..."

(cd ${FABRIC_DIR} && ./channel-create.sh ${TEST_CHANNEL_NAME} 2>&1) | printDbg

printResultAndExit "Channel <$TEST_CHANNEL_NAME> creation run sucsessfuly."
