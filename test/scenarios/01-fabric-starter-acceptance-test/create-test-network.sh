#!/usr/bin/env bash 
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

pushd ${BASEDIR}/../ >/dev/null
BASEDIR=.

export ARGS_REQUIRED="First_organization:org1 Second_organization:org2"

./create-standard-network.sh $@
popd >/dev/null