#!/usr/bin/env bash 

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../../libs/libs.sh
source "${BASEDIR}"/../../libs/parse-common-params.sh $@

export ARGS_REQUIRED="First_organization:org1 Second_organization:org2"

pushd ../>/dev/null
./create-standard-network.sh $@
popd >/dev/null