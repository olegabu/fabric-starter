#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
export TEST_LAUNCH_DIR=$(pwd)

pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh

ARGS_REQUIRED="[Fabric test interface (cli|api|...), First organization, Second organization]"



SCENARIO() {
    
    org1=${1}
    org2=${2}
    
    runStep "Test 'Orderer containers'" \
        VERIFY:   ./test-containers-list.sh "orderer" ${org1} orderer www cli.orderer
    
    runStep "Test '[${org1}] containers'" \
        VERIFY:   ./test-containers-list.sh  "org" ${org1} peer0 api ca cli.peer0 couchdb.peer0 peer0 www
    
    runStep "Test '[${org2}] containers'" \
        VERIFY:   ./test-containers-list.sh "org" ${org2} peer0 api ca cli.peer0 couchdb.peer0 peer0 www
    
    runStep "Test 'Organization in channel [common]'" \
        VERIFY:     test-channel-accessible.sh 'common' ${org1}
    
    runStep "Test 'Organization [${org2}] is in [common] channel'" \
        VERIFY:     test-channel-accessible.sh 'common' ${org2}
    
    runStep "Test 'Organization [${org1}] joined the [common] channel'" \
        VERIFY:  test-join-channel.sh 'common' ${org1}
    
    runStep "Test 'Organization [${org2}] joined the [common] channel'" \
        VERIFY:  test-join-channel.sh 'common' ${org2}
}

export -f SCENARIO

source libs/lib-scenario.sh "${ARGS_REQUIRED}" $@
popd >/dev/null
