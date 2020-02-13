#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh


########################################## $1 ?

export NO_RED_OUTPUT=false


declare types=($(echo $1 | awk -F ',' '{print $1} {print $2}'))

#run scenario
initScenario
printTestResultTable

main () {
    for SCRIPT_FOLDER in "$@"
    do
        RESULTS+=("-|-|-")
        
        export TEST_CHANNEL_NAME=$(getRandomChannelName)
        
        printYellowBox "Running ${SCRIPT_FOLDER} tests"
        addTableRowSeparator
                
        runStep "Test 'Create Channel in ORG1'" "${SCRIPT_FOLDER}" \
            RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${ORG1} \
            VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME} ${ORG1}
        
        runStep "Test 'The channel is not visible in ORG2'" "${SCRIPT_FOLDER}" \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${ORG2}

        runStep "Test 'Can not create the channel with incorrect name in ORG1'" "${SCRIPT_FOLDER}" \
            RUNTEST:    create-channel.sh       "^^^^^^"${TEST_CHANNEL_NAME} ${ORG1} \
            VERIFY:     test-exit-code.sh       
         
        runStep "Test 'Can not create channel in ORG2 with the same name'" "${SCRIPT_FOLDER}" \
            RUN:        export NO_RED_OUTPUT=true \
            RUNTEST:    create-channel.sh  ${TEST_CHANNEL_NAME} ${ORG2} \
            RUN:        export NO_RED_OUTPUT=false \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${ORG2}

        runStep "Test 'Create another channel in ORG2" "${SCRIPT_FOLDER}" \
            RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME}"0" ${ORG2} \
            VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME}"0" ${ORG2}
 
        runStep "Test 'This new channel is not visible in ORG1'" "${SCRIPT_FOLDER}" \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME}"0" ${ORG1}

        runStep "Test 'Can not create channel in ORG1 with the same name'" "${SCRIPT_FOLDER}" \
            RUN:        export NO_RED_OUTPUT=true \
            RUNTEST:    create-channel.sh  ${TEST_CHANNEL_NAME}"0" ${ORG1} \
            RUN:        export NO_RED_OUTPUT= \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME}"0" ${ORG1}


    done

    printTestResultTable
}

main $@