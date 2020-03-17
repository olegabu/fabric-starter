#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${TEST_LAUNCH_DIR}/fs_network_test.log"}}

domain=${1}
export MULTIHOST=
export DOMAIN=$domain

pushd ${FABRIC_DIR} >/dev/null

shift
echo $@

export DOCKER_REGISTRY='localhost:5000'

./clean.sh
./extra/docker-registry-local/start-docker-registry-local.sh
./build_fabric_tools-extended.sh
pushd ${FABRIC_DIR}/../fsg >/dev/null
./build.sh
popd >/dev/null
pwd
DOMAIN=${domain} ./network-create-local.sh $@


