#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
#export TEST_LAUNCH_DIR=$(pwd)

pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh 

deployStandardNetwork

popd >/dev/null