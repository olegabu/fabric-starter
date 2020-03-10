#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${BASEDIR}/fs_network_test.log"}}


export DOMAIN=${1}

pushd ${FABRIC_DIR} >/dev/null

shift

./clean.sh
./extra/docker-registry-local/start-docker-registry-local.sh
./build_fabric_tools-extended.sh
../fsg/build.sh
./network-docker-machine-create.sh $@
./network-create $@


