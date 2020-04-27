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


# Creating channels
    #
    local TEST_CHANNEL_NAME=$(getRandomChannelName)

    local TEST_SECOND_CHANNEL_NAME=${TEST_CHANNEL_NAME}"-02"
    local TEST_CHANNEL_WRONG_NAME="^^^^^^"${TEST_CHANNEL_NAME}

    local TEST_CHAINCODE_NAME=$(getTestChaincodeName ${TEST_CHANNEL_NAME})

    runStep "Test 'Create new channel in ORG1'"   \
        RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${org1} \
        VERIFY:     test-channel-accessible.sh  ${TEST_CHANNEL_NAME} ${org1}


# Adding orgs to channels

    runStep "Test 'Add ORG1 to the first channel created by ORG1'" \
        RUNTEST: add-org-to-channel.sh ${TEST_CHANNEL_NAME} ${org1} ${org1} \
        VERIFY:  test-channel-add-org.sh ${TEST_CHANNEL_NAME} ${org1} ${org1}


    runStep "Test 'Add ORG1 to the first channel created by ORG1'" \
        RUNTEST: add-org-to-channel.sh ${TEST_CHANNEL_NAME} ${org1} ${org1} \
        VERIFY:  test-channel-add-org.sh ${TEST_CHANNEL_NAME} ${org1} ${org1}



    runStep "Test 'Create the second channel in ORG2'" \
	    RUNTEST:    create-channel.sh       ${TEST_SECOND_CHANNEL_NAME} ${org2} \
	    VERIFY:     test-channel-accessible.sh  ${TEST_SECOND_CHANNEL_NAME} ${org2}




    runStep "Test 'Add ORG2 to the second channel created by ORG2'" \
	    RUNTEST: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org2} \
	    VERIFY:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org2}

    runStep "Test 'Add ORG2 to the second channel created by ORG2'" \
	    RUNTEST: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org2} \
	    VERIFY:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org2}




}

export -f SCENARIO

source libs/lib-scenario.sh "${ARGS_REQUIRED}" $@

popd >/dev/null