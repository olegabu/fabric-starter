#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

printToLogAndToScreenBlue "\nVerifing if the <$TEST_CHANNEL_NAME> channel exists in ${ORG}.${DOMAIN}..."

setCurrentActiveOrg ${ORG}

! verifyChannelExists "${TEST_CHANNEL_NAME}" "${ORG}" "$DOMAIN"

printResultAndSetExitCode "The channel <$TEST_CHANNEL_NAME> does not exist and in not visible to ${ORG}"