#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

#Array for test results table rows
declare -a RESULTS
declare step
declare VERIFY_SCRIPT_FOLDER='verify'

#table header
RESULTS+=("STEP|TEST NAME|RESULT")
rowSeparator='-|-|-'

#run scenario
main () {
    for SCRIPT_FOLDER in "$@"
    do
        RESULTS+=("${rowSeparator}")
        export TEST_CHANNEL_NAME=$(getRandomChannelName)
        
        printYellowBox "Running ${SCRIPT_FOLDER} tests"
                
        runStep "Test 'Create Channel in ORG1'" "${SCRIPT_FOLDER}" \
            RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${ORG1} \
            VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME} ${ORG1}
        
        runStep "Test 'The channel is not visible in ORG2'" "${SCRIPT_FOLDER}" \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${ORG2}
        
        runStep "Test 'Can not create channel in ORG2 with the same name'" "${SCRIPT_FOLDER}" \
            RUN:        export NO_RED_OUTPUT=true \
            RUNTEST:    create-channel.sh  ${TEST_CHANNEL_NAME} ${ORG2} \
            RUN:        export NO_RED_OUTPUT= \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${ORG2}
    done

    printTestResultTable "${RESULTS[@]}"
}


function runStep() {
    local message=${1};
    local script_folder=${2}
    shift 2
    local COMMAND=$@

    COMMAND=${COMMAND//RUNTEST:[[:space:]]/" ; ${BASEDIR}/${SCRIPT_FOLDER}/"}
    COMMAND=${COMMAND//VERIFY:[[:space:]]/" ; ${BASEDIR}/${VERIFY_SCRIPT_FOLDER}/"}
    COMMAND=${COMMAND//RUN:[[:space:]]/;}
    COMMAND=$(echo ${COMMAND} | sed -e s'/^;//')


    printWhite "\nStep $((++step))_${script_folder}: ${message}"
    printLog "Step: ${step}_${script_folder} ${message}"
    printLog "$@"
    
    #SET INDENTATION FOR /dev/stdout (1 tabulation symbol)
    exec 3>&1; exec 1> >(paste /dev/null -)
    eval "${COMMAND}" 2>&1
    local exit_code=$?
    
    printDbg "Step ${step}_${script_folder}: exit code $exit_code"

    #RESET INDENTATION FOR /dev/stdout
    exec 1>&3 3>&-
    
    printExitCode "${exit_code}"
    RESULTS+=("${step}_${script_folder}|${message}|${exit_code}")
}


main $@