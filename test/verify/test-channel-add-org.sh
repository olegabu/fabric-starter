#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@
org=$2
orgAdd=$3

printToLogAndToScreenBlue "\nVerifing if the <$orgAdd> added to ${TEST_CHANNEL_NAME} ..."

setCurrentActiveOrg ${orgAdd}

verifyOrgIsInChannel "${TEST_CHANNEL_NAME}" "${orgAdd}" "${DOMAIN}"

printResultAndSetExitCode "Organization <$orgAdd> is in the channel <$TEST_CHANNEL_NAME>."
