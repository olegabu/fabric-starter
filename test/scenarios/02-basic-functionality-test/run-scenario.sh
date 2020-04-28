#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
export TEST_LAUNCH_DIR=$(pwd)


pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh 
echo > ${FSTEST_LOG_FILE}    

ARGS_REQUIRED="[Fabric test interface (cli|api|...), First organization, Second organization]"


SCENARIO() {
    local org1=${1}
    local org2=${2}

    echo "Running scenario for ${org1}, ${org2} orgs in ${DOMAIN}"

        local TEST_CHANNEL_NAME=$(getRandomChannelName)

        local TEST_SECOND_CHANNEL_NAME=${TEST_CHANNEL_NAME}"-02"
        local TEST_CHANNEL_WRONG_NAME="^^^^^^"${TEST_CHANNEL_NAME}

        local TEST_CHAINCODE_NAME=$(getTestChaincodeName ${TEST_CHANNEL_NAME})

# Creating channels
        runStep "Test 'Create new channel in ORG1'"   \
            RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${org1} \
            VERIFY:     test-channel-accessible.sh  ${TEST_CHANNEL_NAME} ${org1}

        runStep "Test 'The channel created in ORG1 is not visible in ORG2'" \
            VERIFY_NOT:     test-channel-accessible.sh      ${TEST_CHANNEL_NAME} ${org2}
        
        runStep "Test 'Can not create a channel with the incorrect name in ORG1'" \
            RUNTEST:    create-channel.sh      ${TEST_CHANNEL_WRONG_NAME} ${org1} \
            VERIFY_NON_ZERO_EXIT_CODE: \
            VERIFY_NOT:     test-channel-accessible.sh  ${TEST_CHANNEL_WRONG_NAME} ${org1}

        runStep "Test 'Can not create channel with the same name in ORG1 again'" \
            RUNTEST:    create-channel.sh  ${TEST_CHANNEL_NAME} ${org1} \
            VERIFY_NON_ZERO_EXIT_CODE: 
        
        runStep "Test 'Can not create a channel in ORG2 with the name of the channel created in ORG1'" \
            RUNTEST:    create-channel.sh  ${TEST_CHANNEL_NAME} ${org2} \
            VERIFY_NON_ZERO_EXIT_CODE:  \
            VERIFY_NOT:     test-channel-accessible.sh      ${TEST_CHANNEL_NAME} ${org2}

        runStep "Test 'Create the second channel in ORG2'" \
            RUNTEST:    create-channel.sh       ${TEST_SECOND_CHANNEL_NAME} ${org2} \
            VERIFY:     test-channel-accessible.sh  ${TEST_SECOND_CHANNEL_NAME} ${org2}

        runStep "Test 'The channel created in ORG2 is not visible in ORG1'" \
            VERIFY_NOT:     test-channel-accessible.sh      ${TEST_SECOND_CHANNEL_NAME} ${org1}

        runStep "Test 'Can not create a channel in ORG1 with the name of the channel created in ORG2'" \
            RUNTEST:   create-channel.sh  ${TEST_SECOND_CHANNEL_NAME} ${org1} \
            VERIFY_NON_ZERO_EXIT_CODE: \
            VERIFY_NOT:     test-channel-accessible.sh      ${TEST_SECOND_CHANNEL_NAME} ${org1}

# Adding orgs to channels
        runStep "Test 'Add ORG1 to the first channel created by ORG1'" \
            RUNTEST: add-org-to-channel.sh ${TEST_CHANNEL_NAME} ${org1} ${org1} \
            VERIFY:  test-channel-add-org.sh ${TEST_CHANNEL_NAME} ${org1} ${org1}
        
        runStep "Test 'Add ORG2 to the second channel created by ORG2'" \
            RUNTEST: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org2} \
            VERIFY:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org2}

        runStep "Test 'Add ORG2 to the first channel created by ORG1'" \
            RUNTEST: add-org-to-channel.sh ${TEST_CHANNEL_NAME} ${org1} ${org2} \
            VERIFY:  test-channel-add-org.sh ${TEST_CHANNEL_NAME} ${org1} ${org2}


        runStep "Test 'Add ORG1 to the second channel created by ORG2'" \
            RUNTEST: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1} \
            VERIFY:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1}

# Joining channels
        runStep "Test 'Join ORG1 to the first chanel created by ORG1'" \
            RUNTEST: join-channel.sh ${TEST_CHANNEL_NAME} ${org1} \
            VERIFY:  test-join-channel.sh ${TEST_CHANNEL_NAME} ${org1}

        runStep "Test 'Join ORG2 to the first chanel created by ORG1'" \
            RUNTEST: join-channel.sh ${TEST_CHANNEL_NAME} ${org2} \
            VERIFY:  test-join-channel.sh ${TEST_CHANNEL_NAME} ${org2}

        runStep "Test 'Join ORG1 to the second chanel created by ORG2'" \
            RUNTEST: join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org1} \
            VERIFY:  test-join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org1}

        runStep "Test 'Join ORG2 to the second chanel created by ORG2'" \
            RUNTEST: join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} \
            VERIFY:  test-join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2}

# Chaincode install
        runStep "Test 'Install test chaincode by ORG1 to the first channel'" \
            RUNTEST: chaincode-install.sh  ${TEST_CHANNEL_NAME} ${org1} \
            VERIFY: test-chaincode-installed.sh ${TEST_CHANNEL_NAME} ${org1}

        runStep "Test 'Install test chaincode by ORG2 to the first channel'" \
            RUNTEST: chaincode-install.sh  ${TEST_CHANNEL_NAME} ${org2} \
            VERIFY: test-chaincode-installed.sh ${TEST_CHANNEL_NAME} ${org2}

        runStep "Test 'Install test chaincode by ORG2 to the second channel'" \
            RUNTEST: chaincode-install.sh  ${TEST_SECOND_CHANNEL_NAME} ${org2} \
            VERIFY: test-chaincode-installed.sh ${TEST_SECOND_CHANNEL_NAME} ${org2}

# Chaincode instantiate
        runStep "Test 'Instantiate test chaincode by ORG1 in the first channel'" \
            RUNTEST: chaincode-instantiate.sh ${TEST_CHANNEL_NAME} ${org1} \
            VERIFY: test-chaincode-instantiated.sh ${TEST_CHANNEL_NAME} ${org1}

# Chaincode verify
        runStep "Test 'Test chaincode invocation in ORG1 and query in ORG2'" \
            RUN: sleep 15 \
            RUNTEST: chaincode-invoke.sh ${TEST_CHANNEL_NAME} ${org1} ${TEST_CHAINCODE_NAME} \
            VERIFY:  test-exit-code.sh \
            RUNTEST: chaincode-query.sh ${TEST_CHANNEL_NAME} ${org2} ${TEST_CHAINCODE_NAME} \
            VERIFY:  test-exit-code.sh
}

export -f SCENARIO

source libs/lib-scenario.sh "${ARGS_REQUIRED}" $@

popd >/dev/null