#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=${2}

printToLogAndToScreenBlue "\nVerifing if the <$TEST_CHANNEL_NAME> channel exists in ${org}.${DOMAIN}..."

setCurrentActiveOrg ${org}

verifyChannelExists "${TEST_CHANNEL_NAME}" "${org}" "${DOMAIN}"

printResultAndSetExitCode "The channel <$TEST_CHANNEL_NAME> exists and visible to ${org}"