#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

declare -a RESULTS
declare step

#shopt -s expand_aliases
#alias setIndent="exec 3>&1; exec 1> >(paste /dev/null -)"

#   Results table header
RESULTS+=("STEP|NAME|RESULT")
#RESULTS+=("==========|===================================|==========")
rowSeparator='----------|-----------------------------------|----------'

main () {
    for SCRIIPT_FOLDER in "$@"
    do
        RESULTS+=("${rowSeparator}")
        export TEST_CHANNEL_NAME=$(getRandomChannelName)
        printYellow "\n\n=================\nRunning ${SCRIIPT_FOLDER} tests\n================="
        
        runStep "Test <Create Channel>" \
        "${SCRIIPT_FOLDER}" ${BASEDIR}/${SCRIIPT_FOLDER}/create-channel.sh ${TEST_CHANNEL_NAME} ${ORG1}\; \
         ${BASEDIR}/verify/test-exist-channel.sh ${TEST_CHANNEL_NAME} ${ORG1}
        
        # runStep "Test 'No  Channel'" \
        # "${SCRIIPT_FOLDER}" ${BASEDIR}/verify/test-exist-channel.sh ${TEST_CHANNEL_NAME} ${ORG2}
        # runStep "Test 'Create Channel'" \
        # "${SCRIIPT_FOLDER}" ${BASEDIR}/${SCRIIPT_FOLDER}/create-channel.sh ${TEST_CHANNEL_NAME} ${ORG2}
        # runStep "Test 'No channel Channel'" \
        # "${SCRIIPT_FOLDER}" ${BASEDIR}/verify/test-exist-channel.sh ${TEST_CHANNEL_NAME} ${ORG1}
    done
    printTestResultTable "${RESULTS[@]}"
}

function runStep() {
    local message=${1};
    local script_folder=${2}
    shift; shift
    local command=$@
    
    printWhite "\nStep $((++step))_${script_folder}: ${message}"
    printLog "Step: ${step}_${script_folder} ${message}"
    printLog "$@"
    exec 3>&1; exec 1> >(paste /dev/null -)
    #setIndent
    eval "$@" 2>&1
    local exit_code=$?
    printDbg "Step ${step}_${script_folder}: exit code $exit_code"
    exec 1>&3 3>&-
    printExitCode "${exit_code}"
    RESULTS+=("${step}_${script_folder}|${message}|${exit_code}")
}


main $@