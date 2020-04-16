#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
export TEST_LAUNCH_DIR=$(pwd)

pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh 

#ARGS_REQUIRED="[Fabric test interface:interface_types,First organization:org1,Second organization:org2]"
ARGS_REQUIRED="[Fabric test interface (cli|api|...), First organization, Second organization]"

interface_types=${1}
org1=${2}
org2=${3}


SCENARIO() {
    runStep "Test 'Orderer containers'" \
        VERIFY:   ./test-containers-list.sh ${org1} ${DOMAIN} orderer www cli.orderer 

    runStep "Test '[${org1}] containers'" \
        VERIFY:   ./test-containers-list.sh  ${org1} ${org1}.${DOMAIN} api ca cli couchdb.peer0 peer0 www

    runStep "Test '[${org2}] containers'" \
        VERIFY:   ./test-containers-list.sh ${org2} ${org2}.${DOMAIN} api ca cli couchdb.peer0 peer0 www

    runStep "Test 'Organization in channel [common]'" \
        VERIFY:     test-channel-exists.sh 'common' ${org1}

    runStep "Test 'Organization [${org2}] is in [common] channel'" \
        VERIFY:     test-channel-exists.sh 'common' ${org2}

     runStep "Test 'Organization [${org1}] joined the [common] channel'" \
         VERIFY:  test-join-channel.sh 'common' ${org1}

     runStep "Test 'Organization [${org2}] joined the [common] channel'" \
         VERIFY:  test-join-channel.sh 'common' ${org2}
}

export -f SCENARIO

source libs/lib-scenario.sh ${interface_types} "${ARGS_REQUIRED}" $@
popd >/dev/null