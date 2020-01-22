#!/usr/bin/env bash

source ./libs.sh
BASEDIR=$(dirname $0)

TEST_INTERFACE=${1:-${TEST_INTERFACE}} #cli or api
#TEST_INTERFACE=cli
export TEST_INTERFACE



FSTEST_LOG_FILE=${FSTEST_LOG_FILE:-"${CURRENT_DIR}/fs_network_test.log"}
[ ! -f ${FSTEST_LOG_FILE} ] || mv ${FSTEST_LOG_FILE} ${FSTEST_LOG_FILE}.prev
export FSTEST_LOG_FILE


case "${TEST_INTERFACE}" in
    cli)
        testinterface="cli"
    ;;
    api)
        testinterface="curl"
    ;;
    curl)
        testinterface="curl"
    ;;
    *)
        echo -e $"\nUsage: \n\n$0 {cli|api} or \nTEST_INTERFACE={cli|api} $0"
        exit 1
esac


#Random channel name to test channel creation
export TEST_CHANNEL_NAME='testlocal'$RANDOM
printDbg "Random channel name = $TEST_CHANNEL_NAME"

#use 'reference' chaincode for testing
CHAINCODE_NAME=${CHAINCODE_NAME:-reference}
printDbg "Chaincode name = $CHAINCODE_NAME"

export DOMAIN=${DOMAIN:-example.com}
export ORG=${ORG:-org1}
export PEER0_PORT=${PEER0_PORT:7051}

printDbg "Running test for ${ORG}.${DOMAIN} for ${FABRIC_DIR}"

#
# Running unit tests
#
printYellow "------------------"
printYellow "Running integration tests"
printYellow "------------------"

function runTest() {
    echo
    printYellow "Step: $((++step))"
    printLog "Step: ${step}"
    printLog "$@"
    eval "$@"
    printDbg "Step ${step}: exit code $?"
    
}

#Creating and validating channel
runTest ${BASEDIR}/${testinterface}/create-channel.sh ${TEST_CHANNEL_NAME}
runTest ${BASEDIR}/verify/test-exist-channel.sh ${TEST_CHANNEL_NAME}

# Another way to call runTests setting the env var
#runTest TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ${BASEDIR}/${testinterface}/create-channel.sh 
#runTest TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ${BASEDIR}/verify/test-exist-channel.sh 

#Addding org to channel and joining it
runTest TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG2='org1' ${BASEDIR}/${testinterface}/add-org-to-channel.sh
runTest TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG2='org1' ${BASEDIR}/verify/test-channel-add-org.sh

runTest TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG2='org2' ${BASEDIR}/${testinterface}/add-org-to-channel.sh
runTest TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG2='org2' ${BASEDIR}/verify/test-channel-add-org.sh

runTest PEER0_PORT=7051 TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org1 ${BASEDIR}/${testinterface}/join-channel.sh
runTest PEER0_PORT=8051 TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org2 ${BASEDIR}/${testinterface}/join-channel.sh


runTest PEER0_PORT=7051 TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org1 ${BASEDIR}/verify/test-join-channel.sh
runTest PEER0_PORT=8051 TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org2 ${BASEDIR}/verify/test-join-channel.sh



runTest PEER0_PORT=7051 CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org1 ${BASEDIR}/${testinterface}/chaincode-install.sh ${TEST_CHANNEL_NAME}
runTest PEER0_PORT=7051 CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org2 ${BASEDIR}/${testinterface}/chaincode-install.sh ${TEST_CHANNEL_NAME}


runTest PEER0_PORT=7051 CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org1 ${BASEDIR}/verify/test-chaincode-install.sh
runTest PEER0_PORT=8051 CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org2 ${BASEDIR}/verify/test-chaincode-install.sh


runTest PEER0_PORT=7051 CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org1 ${BASEDIR}/${testinterface}/chaincode-instantiate.sh ${TEST_CHANNEL_NAME}
sleep 10
runTest PEER0_PORT=7051 CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org1 ${BASEDIR}/verify/test-chaincode-instantiated.sh ${TEST_CHANNEL_NAME}



#runTest PEER0_PORT=7051 CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org1 ${BASEDIR}/${testinterface}/test-chaincode-install-instantiate.sh
sleep 10
runTest CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG1=org1 ORG2=org2 ${BASEDIR}/verify/test-chaincode-data-exchange.sh

exit

echo
printYellow "Step: $((++step))"
echo "Step: $step" | tee -a $FSTEST_LOG_FILE > /dev/null
TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME $BASEDIR/test-create-channel.sh
echo "Step exit code $?" | tee -a $FSTEST_LOG_FILE

echo
printYellow "Step: $((++step))"
echo "Step: $step" | tee -a $FSTEST_LOG_FILE > /dev/null
TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG2='org2' $BASEDIR/test-add-to-org.sh
echo "Step exit code $?" | tee -a $FSTEST_LOG_FILE

echo
printYellow "Step: $((++step))"
echo "Step: $step" | tee -a $FSTEST_LOG_FILE > /dev/null
PEER0_PORT=7051 TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG=org1 $BASEDIR/test-join-channel.sh
echo "Step exit code $?" | tee -a $FSTEST_LOG_FILE

echo
printYellow "Step: $((++step))"
echo "Step: $step" | tee -a $FSTEST_LOG_FILE > /dev/null
PEER0_PORT=8051 TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG=org2 $BASEDIR/test-join-channel.sh
echo "Step exit code $?" | tee -a $FSTEST_LOG_FILE

echo
printYellow "Step: $((++step))"
echo "Step: $step" | tee -a $FSTEST_LOG_FILE > /dev/null
PEER0_PORT=7051 CHAINCODE_NAME=$CHAINCODE_NAME TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG=org1 $BASEDIR/test-chaincode-install-instantiate.sh
echo "Step  exit code $?" | tee -a $FSTEST_LOG_FILE

echo
printYellow "Step: $((++step))"
echo "Step: $step" | tee -a $FSTEST_LOG_FILE > /dev/null
PEER0_PORT=8051 CHAINCODE_NAME=$CHAINCODE_NAME TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG=org2 $BASEDIR/test-chaincode-install-instantiate.sh
echo "Step  exit code $?" | tee -a $FSTEST_LOG_FILE

echo
printYellow "Step: $((++step))"
echo "Step: $step" | tee -a $FSTEST_LOG_FILE > /dev/null
CHAINCODE_NAME=$CHAINCODE_NAME TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG1=org1 ORG2=org2 $BASEDIR/test-chaincode-data-exchange.sh
echo "Step exit code $?" | tee -a $FSTEST_LOG_FILE