#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
export TEST_LAUNCH_DIR=$(pwd)

pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh 

#echo "run_scenario.sh $$ : Starting in $BRIGHT $RED $(pwd), $WHITE Basedir is $BASEDIR $NORMAL"

ARGS_PASSED=("$@")

ARGS_REQUIRED=(
    "Fabric_test_interface":interface_types
    "First_organization":org1
    "Second_organization":org2
)


SCENARIO() {
    
    runStep "Test 'Docker containers for orderer are up and running'" "${SCRIPT_FOLDER}" \
        VERIFY:   ./test-containers-list.sh ${org1} ${DOMAIN} orderer www cli.orderer 

    runStep "Test 'Docker containers for <${org1}> are up and running'" "${SCRIPT_FOLDER}" \
        VERIFY:   ./test-containers-list.sh  ${org1} ${org1}.${DOMAIN} api ca cli couchdb.peer0 peer0 www

    runStep "Test 'Docker containers for <${org2}> are up and running'" "${SCRIPT_FOLDER}" \
        VERIFY:   ./test-containers-list.sh ${org2} ${org2}.${DOMAIN} api ca cli couchdb.peer0 peer0 www

    runStep "Test 'Organization <${org1}> is in <common> channel'" "${SCRIPT_FOLDER}" \
        VERIFY:     test-channel-exists.sh 'common' ${org1} 

    runStep "Test 'Organization <${org2}> is in <common> channel'" "${SCRIPT_FOLDER}" \
        VERIFY:     test-channel-exists.sh 'common' ${org2} 

     runStep "Test 'Organization <${org1}> joined the <common> channel'" "${SCRIPT_FOLDER}" \
         VERIFY:  test-join-channel.sh 'common' ${org1}

     runStep "Test 'Organization <${org2}> joined the <common> channel'" "${SCRIPT_FOLDER}" \
         VERIFY:  test-join-channel.sh 'common' ${org2}
}

export -f SCENARIO


source libs/lib-scenario.sh $@

popd >/dev/null