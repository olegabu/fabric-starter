#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

ARGS_PASSED=("$@")

ARGS_REQUIRED=(
    "Fabric_test_interface":interface_type
    "First_organization":org1
    "Second_organization":org2
  #  "Domain":DOMAIN
)

scenarioArgsParse #using ARGS_REQUIRED ARGS_PASSED to set vars
initResultsTable

TYPES=($(sed -e 's/,/ /g' <<<${interface_type}))

#run scenario
main () {
    for SCRIPT_FOLDER in "${TYPES[@]}"
    do

        export TEST_CHANNEL_NAME=$(getRandomChannelName)
        printYellowBox "Running ${SCRIPT_FOLDER} tests"
        addTableRowSeparator

        TEST_CHANNEL_WRONG_NAME="^^^^^^"${TEST_CHANNEL_NAME}
        TEST_SECOND_CHANNEL_NAME=${TEST_CHANNEL_NAME}"02"

        runStep "Test 'Create Channel in ORG1'" "${SCRIPT_FOLDER}" \
            RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${org1} \
            VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME} ${org1} 
        
        runStep "Test 'The channel is not visible in ORG2'" "${SCRIPT_FOLDER}" \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${org2}

        runStep "Test 'Can not create the channel with incorrect name in ORG1'" "${SCRIPT_FOLDER}" \
            RUNTESTNOERRPRINT:   create-channel.sh      ${TEST_CHANNEL_WRONG_NAME} ${org1} \
            VERIFY:     test-channel-does-not-exist.sh  ${TEST_CHANNEL_WRONG_NAME} ${org1}

        runStep "Test 'Can not create channel in ORG2 with the same name'" "${SCRIPT_FOLDER}" \
            RUNTESTNOERRPRINT:   create-channel.sh  ${TEST_CHANNEL_NAME} ${org2} \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${org2}

        runStep "Test 'Create another channel in ORG2" "${SCRIPT_FOLDER}" \
            RUNTEST:    create-channel.sh       ${TEST_SECOND_CHANNEL_NAME} ${org2} \
            VERIFY:     test-channel-exists.sh  ${TEST_SECOND_CHANNEL_NAME} ${org2}

        runStep "Test 'This new channel is not visible in ORG1'" "${SCRIPT_FOLDER}" \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_SECOND_CHANNEL_NAME} ${org1}

        runStep "Test 'Can not create channel in ORG1 with the same name'" "${SCRIPT_FOLDER}" \
            SKIP: \
            RUNTESTNOERRPRINT:   create-channel.sh  ${TEST_SECOND_CHANNEL_NAME} ${org1} \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_SECOND_CHANNEL_NAME} ${org1} 
    done

    printTestResultTable
}

main $@