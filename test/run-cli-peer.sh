#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

main() {

local compose_org=${1}
local command=${@:2}

libcommand='source container-scripts/lib/container-lib.sh 2>/dev/null'
FABRIC_DIR=${FABRIC_DIR:-$BASEDIR/..}

pushd "${FABRIC_DIR}" >/dev/null

COMPOSE_PROJECT_NAME=${compose_org} docker-compose -f ${FABRIC_DIR}/docker-compose.yaml exec -T cli.peer bash -c "${libcommand}; ${command}"
local exitCode=$?
popd > /dev/null

[ "${exitCode}" = "0" ]
}

main ${@}