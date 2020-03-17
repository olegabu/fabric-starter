#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${TEST_LAUNCH_DIR}/fs_network_test.log"}}


export DOMAIN=${1}

pushd ${FABRIC_DIR} >/dev/null

shift

echo $@
./clean.sh

docker stop registry
./extra/docker-registry-local/start-docker-registry-local.sh

echo build fabric tools extended......
./build_fabric_tools-extended.sh

cd ../fsg
./build.sh


cd ../fabric-starter
./network-docker-machine-create.sh $@
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#pwd
#DOMAIN=${DOMAIN} ./network-create.sh $@


