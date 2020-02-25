#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/../libs.sh
source ${BASEDIR}/../parse-common-params.sh $@

printToLogAndToScreenBlue "\nVerifing if the ${ORG} has joined the <$TEST_CHANNEL_NAME> channel..."

setCurrentActiveOrg ${ORG}

verifyOrgJoinedChannel "${TEST_CHANNEL_NAME}" "${ORG}" "${DOMAIN}"

printResultAndSetExitCode "The ${ORG} has joined the <$TEST_CHANNEL_NAME> channel"
