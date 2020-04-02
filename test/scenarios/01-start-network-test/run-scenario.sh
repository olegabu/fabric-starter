#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
export TEST_LAUNCH_DIR=$(pwd)

pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh 


ARGS_REQUIRED="[Fabric test interface:interface_types,First organization:org1,Second organization:org2]"

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

source libs/lib-scenario.sh "${ARGS_REQUIRED}" $@

popd >/dev/null