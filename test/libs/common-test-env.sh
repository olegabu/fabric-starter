#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh


echo
echo "Network config dir: ${NETCONFPATH}"
echo "Test log file: ${FSTEST_LOG_FILE}"
echo "Fabric dir: ${FABRIC_DIR}"
echo "Test Suite root dir: ${TEST_ROOT_DIR}"
