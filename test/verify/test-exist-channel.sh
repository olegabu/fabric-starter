#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh
source ${BASEDIR}/../parse-common-params.sh $@

printLogScreenCyan "Verifing if the <$TEST_CHANNEL_NAME> channel exists in ${ORG}.${DOMAIN}..."

verifyChannelExists "${TEST_CHANNEL_NAME}" "${ORG}" 

printResultAndSetExitCode "The channel <$TEST_CHANNEL_NAME> exists and visible to ${ORG}"
