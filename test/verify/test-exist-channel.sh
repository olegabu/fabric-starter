#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME:? Channel name is required.}}
ORG=${2:-$ORG1}

printLogScreenCyan "Verifing if the <$TEST_CHANNEL_NAME> channel exists in ${ORG}.${DOMAIN}..."

result=$(verifyChannelExists "${TEST_CHANNEL_NAME}" "${ORG}")

printAndCompareResults \
"\nOK: The channel <$TEST_CHANNEL_NAME> exists in ${ORG}" \
"\nERROR: The <$TEST_CHANNEL_NAME> channel does not exist in ${ORG}!\nSee ${FSTEST_LOG_FILE} for logs." \
${result} ${TEST_CHANNEL_NAME}