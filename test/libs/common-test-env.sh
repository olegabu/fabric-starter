#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

export DOMAIN=${1:-${DOMAIN:-example.com}}

echo
echo "Test log file: ${FSTEST_LOG_FILE}"
echo "Fabric dir: ${FABRIC_DIR}"
echo "Test Suite root dir: ${TEST_ROOT_DIR}"
