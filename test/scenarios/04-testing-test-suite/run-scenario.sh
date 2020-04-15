#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
export TEST_LAUNCH_DIR=$(pwd)


pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh 
echo > ${FSTEST_LOG_FILE}    

#echo "run_scenario.sh $$ : Starting in $BRIGHT $RED $(pwd), $WHITE Basedir is $BASEDIR $NORMAL"

ARGS_REQUIRED="[Fabric test interface (cli|api|...), First organization, Second organization]"

interface_types=${1}
org1=${2}
org2=${3}




SCENARIO() {
    
#    SCRIPT_FOLDER=$1 #cli|curl
#    TEST_CHANNEL_NAME=$2
#    TEST_CHAINCODE_NAME=$3

echo "Running scenario for ${TEST_CHANNEL_NAME} ${org1} ${org2}"


# Creating channels    

    TEST_CHANNEL_WRONG_NAME="^^^^^^"${TEST_CHANNEL_NAME}
    TEST_SECOND_CHANNEL_NAME=${TEST_CHANNEL_NAME}"-02"


    runStep "Test 'Create another channel in ORG2'" \
        RUNTEST:    create-channel.sh       ${TEST_SECOND_CHANNEL_NAME} ${org2} \
        VERIFY:     test-channel-exists.sh  ${TEST_SECOND_CHANNEL_NAME} ${org2}


    runStep "Test 'Can not create the same channel in ORG2'" \
        RUNTEST:    create-channel.sh       ${TEST_SECOND_CHANNEL_NAME} ${org2} \
	VERIFY_NON_ZERO_EXIT_CODE: \
        VERIFY:     test-channel-exists.sh  ${TEST_SECOND_CHANNEL_NAME} ${org2}

    runStep "Test 'Add ORG1 to the second channel created by ORG2'" \
        RUNTEST: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1} \
        VERIFY:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1}


    runStep "Test 'Add ORG1 to the second channel created by ORG2'" \
        RUNTEST: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME}_ ${org1} ${org1} \
	VERIFY_NON_ZERO_EXIT_CODE: \
        VERIFY_NOT:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME}_ ${org1} ${org1}



#	    VERIFY:     test-exit-code.sh \


if false; then

# Adding orgs to channels

    runStep "Test 'Add ORG1 to the second channel created by ORG2'" \
        RUNTEST: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1} \
        VERIFY:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1}


    runStep "Test 'Add ORG1 to the second channel created by ORG2'" \
        RUNTEST: add-org-to-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1} \
        VERIFY:  test-channel-add-org.sh ${TEST_SECOND_CHANNEL_NAME} ${org2} ${org1}

fi

# Joining channels

    runStep "Test 'Join ORG1 to the second chanel created by ORG2'" \
        RUNTEST: join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org1} \
        VERIFY:  test-join-channel.sh ${TEST_SECOND_CHANNEL_NAME} ${org1}

}

export -f SCENARIO

source libs/lib-scenario.sh ${interface_types} "${ARGS_REQUIRED}" $@

popd >/dev/null