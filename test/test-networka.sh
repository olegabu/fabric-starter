#!/usr/bin/env bash

source ./libs.sh

TEST_INTERFACE=${1:-${TEST_INTERFACE}} #cli or api
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
echo "Random channel name = $TEST_CHANNEL_NAME" | tee -a ${FSTEST_LOG_FILE} > "${output}"

#use 'reference' chaincode for testing
CHAINCODE_NAME=${CHAINCODE_NAME:-reference}
echo "Chaincode name = $CHAINCODE_NAME" | tee -a ${FSTEST_LOG_FILE} > "${output}"

export DOMAIN=${DOMAIN:-example.com}
export ORG=${ORG:-org1}
export PEER0_PORT=${PEER0_PORT:7051}





echo "Running test for ${ORG}.${DOMAIN} for ${FABRIC_DIR}" | tee -a ${FSTEST_LOG_FILE} > "${output}"

#
# Running unit tests
#
printYellow "------------------"
printYellow "Running integration tests"
printYellow "------------------"

function runTest() {
    echo
    printYellow "Step: $((++step))"
    echo "Step: ${step}" | tee -a ${FSTEST_LOG_FILE} > /dev/null
    echo "$@" | tee -a ${FSTEST_LOG_FILE} > "${output}"
    eval "$@"
    echo "Step ${step}: exit code $?" | tee -a ${FSTEST_LOG_FILE}
}

runTest TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ${BASEDIR}/${testinterface}/test-create-channel.sh
runTest TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ${BASEDIR}/verify/test-exist-channel.sh

exit
runTest TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG2='org2' ${BASEDIR}/test-add-to-org.sh
runTest PEER0_PORT=7051 TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org1 ${BASEDIR}/test-join-channel.sh
runTest PEER0_PORT=8051 TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org2 ${BASEDIR}/test-join-channel.sh
runTest PEER0_PORT=7051 CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org1 ${BASEDIR}/test-chaincode-install-instantiate.sh
runTest PEER0_PORT=8051 CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG=org2 ${BASEDIR}/test-chaincode-install-instantiate.sh
runTest CHAINCODE_NAME=${CHAINCODE_NAME} TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME} ORG1=org1 ORG2=org2 ${BASEDIR}/test-chaincode-data-exchange.sh

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