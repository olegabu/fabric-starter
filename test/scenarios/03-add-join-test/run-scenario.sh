#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
export TEST_LAUNCH_DIR=$(pwd)

pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh 

ARGS_REQUIRED="[Fabric test interface (cli|api|...), First organization, Second organization]"

interface_types=${1}
org1=${2}
org2=${3}


SCENARIO() {
    
#    SCRIPT_FOLDER=$1 #cli|curl
#    TEST_CHANNEL_NAME=$2
#    TEST_CHAINCODE_NAME=$3

# Creating channels    

    TEST_CHANNEL_WRONG_NAME="^^^^^^"${TEST_CHANNEL_NAME}
    TEST_SECOND_CHANNEL_NAME=${TEST_CHANNEL_NAME}"-02"

    runStep "Test 'Create Channel in ORG1'" \
        RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${org1} \
        VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME} ${org1}


    runStep "Test 'Create Channel in ORG2'" \
        RUNTEST:    create-channel.sh       ${TEST_SECOND_CHANNEL_NAME} ${org2} \
        VERIFY:     test-channel-exists.sh  ${TEST_SECOND_CHANNEL_NAME} ${org2}


# Adding org to channel
    runStep "Test 'Add <${org2}> to channel <${TEST_CHANNEL_NAME}> created by the <${org1}> org'" \
        RUNTESTNOERRPRINT: add-org-to-channel.sh ${TEST_CHANNEL_NAME} ${org1} ${org2} \
        VERIFY:  test-channel-add-org.sh ${TEST_CHANNEL_NAME} ${org1} ${org2}


#if false; then    
    runStep "Test 'Add <${org1}> to channel <${TEST_SECOND_CHANNEL_NAME}> created by the <${org2}> org'"  \
        RUNTESTNOERRPRINT: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1} \
        VERIFY:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1}

# Joining channels

    runStep "Test 'Join <${org1}> to the <${TEST_CHANNEL_NAME}> chanel created by the <${org1}> org'" \
        RUNTESTNOERRPRINT: join-channel.sh ${TEST_CHANNEL_NAME} ${org1} \
        VERIFY:  test-join-channel.sh ${TEST_CHANNEL_NAME} ${org1}


    runStep "Test 'Join <${org2}> to the <${TEST_CHANNEL_NAME}> chanel created by the <${org1}> org'" \
        RUNTESTNOERRPRINT: join-channel.sh ${TEST_CHANNEL_NAME} ${org2} \
        VERIFY:  test-join-channel.sh ${TEST_CHANNEL_NAME} ${org2}
            
    runStep "Test 'Join <${org1}> to the <${TEST_SECOND_CHANNEL_NAME}> chanel created by the <${org2}> org'" \
        RUNTESTNOERRPRINT: join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org1} \
        VERIFY:  test-join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org1}


    runStep "Test 'Join <${org2}> to the <${TEST_SECOND_CHANNEL_NAME}> chanel created by the <${org2}> org'"  \
        RUNTESTNOERRPRINT: join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} \
        VERIFY:  test-join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2}

}


export -f SCENARIO
source libs/lib-scenario.sh ${interface_types} "${ARGS_REQUIRED}" $@

popd >/dev/null