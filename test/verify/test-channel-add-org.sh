#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@
org2_=$3

printToLogAndToScreenBlue "\nVerifing if the <$org2_> added to ${TEST_CHANNEL_NAME} ..."

setCurrentActiveOrg ${ORG}

verifyOrgIsInChannel "${TEST_CHANNEL_NAME}" "${org2_}" "${DOMAIN}"

printResultAndSetExitCode "Organization <$org2_> is in the channel <$TEST_CHANNEL_NAME>."
