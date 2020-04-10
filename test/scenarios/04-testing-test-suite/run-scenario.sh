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


     runStep "Test 'Create new channel in ORG1'"   \
	RUNTEST:    create-channel.sh       "^^^^^"${TEST_CHANNEL_NAME} ${org1} \
	VERIFY:     test-exit-code.sh \
	VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME} ${org1}

    # runStep "Test 'The channel created in ORG1 is not visible in ORG2'" \
    #     VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${org2}
    
    runStep "Test 'Can not create a channel with the incorrect name in ORG1'" \
	RUNTEST:    create-channel.sh      ${TEST_CHANNEL_WRONG_NAME} ${org1} \
	VERIFY:     test-exit-code.sh \$? 1\
	VERIFY:     ! test-channel-exists.sh  ${TEST_CHANNEL_WRONG_NAME} ${org1} 
    # runStep "Test 'Can not create a channel in ORG1 again'" \
    #     RUNTEST:    can-not-create-channel.sh  ${TEST_CHANNEL_NAME} ${org1} \
    #     VERIFY:     test-channel-does-not-exist.sh      ${TEST_CHANNEL_NAME} ${org1}

}

export -f SCENARIO

source libs/lib-scenario.sh ${interface_types} "${ARGS_REQUIRED}" $@

popd >/dev/null