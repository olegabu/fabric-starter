#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

export DOMAIN=${1:-${DOMAIN:-example.com}}

#source ${BASEDIR}/parse-common-params.sh $TEST_CHANNEL_NAME $2 $3
#source ${BASEDIR}/parse-common-params.sh $TEST_CHANNEL_NAME $@

#source ${BASEDIR}/parse-common-params.sh $@

#export ORG1=${2:-org1}
#export ORG2=${3:-org2}

echo
echo "Test log file: ${FSTEST_LOG_FILE}"
echo "Fabric dir: ${FABRIC_DIR}"
echo "Test Suite root dir: ${TEST_ROOT_DIR}"