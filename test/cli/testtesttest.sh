#!/usr/bin/env bash


[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${BASEDIR}/fs_network_test.log"}}

source "${BASEDIR}"/../libs/libs.sh

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}

channelCreateExitCode=0


#    if [[ "$channelCreateExitCode" -eq 0 ]]; then
#    printGreen "\nOK: Channel <$TEST_CHANNEL_NAME> created successfully."
#        exit 0
#    else
#    printError "\nERROR: Creating channel <$TEST_CHANNEL_NAME> failed!\nSee ${FSTEST_LOG_FILE} for logs."
#        exit 1
#    fi
#    echo"\n\n"


function printAndCompareResults() {

var="$1"; 	value="$2"
messageOK="$3";messageERR="$4"

    if [[ "$var" -eq "$value" ]]; then
    printGreen "${messageOK}"
        exit 0
    else
    printError "${messageERR}"
        exit 1
    fi
}

printAndCompareResults $channelCreateExitCode 0 "\nOK: Channel <$TEST_CHANNEL_NAME> created successfully." "\nERROR: Creating channel <$TEST_CHANNEL_NAME> failed!\nSee ${FSTEST_LOG_FILE} for logs."


