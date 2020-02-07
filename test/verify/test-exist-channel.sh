#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/../libs.sh
source ${BASEDIR}/../parse-common-params.sh $@

printLogScreenCyan "Verifing if the <$TEST_CHANNEL_NAME> channel exists in ${ORG}.${DOMAIN}..."

setCurrentActiveOrg ${ORG}

verifyChannelExists "${TEST_CHANNEL_NAME}" "${ORG}"

printResultAndSetExitCode "The channel <$TEST_CHANNEL_NAME> exists and visible to ${ORG}"