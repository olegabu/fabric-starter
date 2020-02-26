#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

ARGS_PASSED=("$@")

ARGS_REQUIRED=(
    "Fabric_test_interface":interface_types
    "First_organization":org1
    "Second_organization":org2
)


SCENARIO() {
    
    SCRIPT_FOLDER=$1 #cli|curl
    TEST_CHANNEL_NAME=$2

# Creating channels    

    TEST_CHANNEL_WRONG_NAME="^^^^^^"${TEST_CHANNEL_NAME}
    TEST_SECOND_CHANNEL_NAME=${TEST_CHANNEL_NAME}"-02"

    runStep "Test 'Create Channel in ORG1'" "${SCRIPT_FOLDER}" \
        RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${org1} \
        VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME} ${org1}
#if false; then    
    
    runStep "Test 'The channel is not visible in ORG2'" "${SCRIPT_FOLDER}" \
        VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${org2}
    
    runStep "Test 'Can not create the channel with incorrect name in ORG1'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT:   create-channel.sh      ${TEST_CHANNEL_WRONG_NAME} ${org1} \
        VERIFY:     test-channel-does-not-exist.sh  ${TEST_CHANNEL_WRONG_NAME} ${org1}
    
    runStep "Test 'Can not create channel in ORG2 with the same name'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT:   create-channel.sh  ${TEST_CHANNEL_NAME} ${org2} \
        VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${org2}
#fi    
    runStep "Test 'Create another channel in ORG2" "${SCRIPT_FOLDER}" \
        RUNTEST:    create-channel.sh       ${TEST_SECOND_CHANNEL_NAME} ${org2} \
        VERIFY:     test-channel-exists.sh  ${TEST_SECOND_CHANNEL_NAME} ${org2}
#if false; then    
    
    runStep "Test 'This new channel is not visible in ORG1'" "${SCRIPT_FOLDER}" \
        VERIFY:     test-channel-does-not-exist.sh      ${TEST_SECOND_CHANNEL_NAME} ${org1}

    runStep "Test 'Can not create channel in ORG1 with the same name'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT:   create-channel.sh  ${TEST_SECOND_CHANNEL_NAME} ${org1} \
        VERIFY:     test-channel-does-not-exist.sh      ${TEST_SECOND_CHANNEL_NAME} ${org1}
#fi
# Adding org to channel
    runStep "Test 'Add <${org2}> to channel <${TEST_CHANNEL_NAME}> created by the <${org1}> org'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT: add-org-to-channel.sh ${TEST_CHANNEL_NAME} ${org1} ${org2} \
        VERIFY:  test-channel-add-org.sh ${TEST_CHANNEL_NAME} ${org1} ${org2}

    runStep "Test 'Add <${org1}> to channel <${TEST_SECOND_CHANNEL_NAME}> created by the <${org2}> org'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1} \
        VERIFY:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1}

# Joining channels

    runStep "Test 'Join <${org2}> to the <${TEST_CHANNEL_NAME}> chanel created by the <${org1}> org'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT: join-channel.sh ${TEST_CHANNEL_NAME} ${org2} \
        VERIFY:  test-join-channel.sh ${TEST_CHANNEL_NAME} ${org2}
            
    runStep "Test 'Join <${org1}> to the <${TEST_SECOND_CHANNEL_NAME}> chanel created by the <${org2}> org'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT: join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org1} \
        VERIFY:  test-join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org1}

 

# Chaincode install

# Chaincode instantiate

# Chaincode verify




}

export -f SCENARIO
source ${BASEDIR}/lib-scenario.sh $@