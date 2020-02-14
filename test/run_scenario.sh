#!/usr/bin/env zsh

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

ARGS_PASSED=("$@")

ARGS_REQUIRED=(
    "Fabric_test_interface":interface_type
    "First_organization":org1
    "Second_organization":org2
#    "Domain":DOMAIN
)


echo ${ARGS_PASSED[0]}

scenarioArgsParse #ARGS_REQUIRED ARGS_PASSED
initResultsTable

TYPES=($(sed -e 's/,/ /g' <<<${interface_type}))

export NO_RED_OUTPUT=false

#run scenario
main () {
    for SCRIPT_FOLDER in "${TYPES[@]}"
    do

        export TEST_CHANNEL_NAME=$(getRandomChannelName)

        printYellowBox "Running ${SCRIPT_FOLDER} tests"
        addTableRowSeparator

        runStep "Test 'Create Channel in ORG1'" "${SCRIPT_FOLDER}" \
            RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${org1} \
            VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME} ${org1}

        runStep "Test 'The channel is not visible in ORG2'" "${SCRIPT_FOLDER}" \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${org2}

        runStep "Test 'Can not create the channel with incorrect name in ORG1'" "${SCRIPT_FOLDER}" \
            RUNTEST:    create-channel.sh       "^^^^^^"${TEST_CHANNEL_NAME} ${org1} \
            VERIFY:     test-exit-code.sh

        runStep "Test 'Can not create channel in ORG2 with the same name'" "${SCRIPT_FOLDER}" \
            RUN:        export NO_RED_OUTPUT=true \
            RUNTEST:    create-channel.sh  ${TEST_CHANNEL_NAME} ${org2} \
            RUN:        export NO_RED_OUTPUT=false \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${org2}

        runStep "Test 'Create another channel in ORG2" "${SCRIPT_FOLDER}" \
            RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME}"0" ${org2} \
            VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME}"0" ${org2}

        runStep "Test 'This new channel is not visible in ORG1'" "${SCRIPT_FOLDER}" \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME}"0" ${org1}

        runStep "Test 'Can not create channel in ORG1 with the same name'" "${SCRIPT_FOLDER}" \
            RUN:        export NO_RED_OUTPUT=true \
            RUNTEST:    create-channel.sh  ${TEST_CHANNEL_NAME}"0" ${org1} \
            RUN:        export NO_RED_OUTPUT= \
            VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME}"0" ${org1}


    done

    printTestResultTable
}

main $@