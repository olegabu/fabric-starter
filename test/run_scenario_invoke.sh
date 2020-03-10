#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs/libs.sh

ARGS_PASSED=("$@")

ARGS_REQUIRED=(
    "Fabric_test_interface":interface_types
    "First_organization":org1
    "Second_organization":org2
)


SCENARIO() {
    
    SCRIPT_FOLDER=$1 #cli|curl
    TEST_CHANNEL_NAME=$2
    TEST_CHAINCODE_NAME=$3

# Creating channels    

    TEST_CHANNEL_WRONG_NAME="^^^^^^"${TEST_CHANNEL_NAME}
    TEST_SECOND_CHANNEL_NAME=${TEST_CHANNEL_NAME}"-02"

    runStep "Test 'Create Channel in ORG1'" "${SCRIPT_FOLDER}" \
        RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${org1} \
        VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME} ${org1}


# Adding org to channel

    runStep "Test 'Add <${org1}> to channel <${TEST_CHANNEL_NAME}> created by the <${org1}> org'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT: add-org-to-channel.sh ${TEST_CHANNEL_NAME} ${org1} ${org1} \
        VERIFY:  test-channel-add-org.sh ${TEST_CHANNEL_NAME} ${org1} ${org1}

    runStep "Test 'Add <${org2}> to channel <${TEST_CHANNEL_NAME}> created by the <${org1}> org'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT: add-org-to-channel.sh ${TEST_CHANNEL_NAME} ${org1} ${org2} \
        VERIFY:  test-channel-add-org.sh ${TEST_CHANNEL_NAME} ${org1} ${org2}


# Joining channels

    runStep "Test 'Join <${org1}> to the <${TEST_CHANNEL_NAME}> chanel created by the <${org1}> org'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT: join-channel.sh ${TEST_CHANNEL_NAME} ${org1} \
        VERIFY:  test-join-channel.sh ${TEST_CHANNEL_NAME} ${org1}

    runStep "Test 'Join <${org2}> to the <${TEST_CHANNEL_NAME}> chanel created by the <${org1}> org'" "${SCRIPT_FOLDER}" \
        RUNTESTNOERRPRINT: join-channel.sh ${TEST_CHANNEL_NAME} ${org2} \
        VERIFY:  test-join-channel.sh ${TEST_CHANNEL_NAME} ${org2}

#if false; then
# Chaincode install
    runStep "Test 'Install test chaincode by <${org1}> to the <${TEST_CHANNEL_NAME}> channel'" "${SCRIPT_FOLDER}" \
	RUNTEST: chaincode-install.sh  ${TEST_CHANNEL_NAME} ${org1} \
        VERIFY: test-chaincode-installed.sh ${TEST_CHANNEL_NAME} ${org1}


    runStep "Test 'Install test chaincode by <${org2}> to the <${TEST_CHANNEL_NAME}> channel'" "${SCRIPT_FOLDER}" \
	RUNTEST: chaincode-install.sh  ${TEST_CHANNEL_NAME} ${org2} \
        VERIFY: test-chaincode-installed.sh ${TEST_CHANNEL_NAME} ${org2}


# Chaincode instantiate

    runStep "Test 'Instantiate test chaincode by <${org1}> to the <${TEST_CHANNEL_NAME}> channel'" "${SCRIPT_FOLDER}" \
	RUNTEST: chaincode-instantiate.sh ${TEST_CHANNEL_NAME} ${org1} \
        VERIFY: test-chaincode-instantiated.sh ${TEST_CHANNEL_NAME} ${org1}


# Chaincode verify operation

    runStep "Test 'Test chaincode invocation and query:  <${org1}> <-> <$org2>'" "${SCRIPT_FOLDER}" \
	RUNTEST: chaincode-invoke.sh ${TEST_CHANNEL_NAME} ${org1} ${TEST_CHAINCODE_NAME} \
	RUN: sleep 5 \
	RUNTEST: chaincode-query.sh ${TEST_CHANNEL_NAME} ${org2} ${TEST_CHAINCODE_NAME}
#        VERIFY: test-chaincode-invoke-result.sh ${TEST_CHANNEL_NAME} ${org2}
#fi
}

export -f SCENARIO
source ${BASEDIR}/libs/lib-scenario.sh $@