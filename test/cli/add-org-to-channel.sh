#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
source "${BASEDIR}"/../libs/parse-common-params.sh $@

org=$2
orgAdd=$3

printToLogAndToScreenCyan "\nAdd [${orgAdd}] to the [${TEST_CHANNEL_NAME}] channel"

setCurrentActiveOrg ${org}

runInFabricDir ./channel-add-org.sh ${TEST_CHANNEL_NAME} ${orgAdd}

printResultAndSetExitCode "Organization [${orgAdd}] added to [${TEST_CHANNEL_NAME}] channel"