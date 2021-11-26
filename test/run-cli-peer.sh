#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

org=${1}
command=${@:2}

libcommand='source container-scripts/lib/container-lib.sh 2>/dev/null'

FABRIC_DIR=${FABRIC_DIR:-$BASEDIR/..}

source ${FABRIC_DIR}/org_env 2>/dev/null
[ $? -ne 0 ] && source ${FABRIC_DIR}/${org}_env;

ENROLL_ID=${ENROLL_ID} COMPOSE_PROJECT_NAME=${org} docker-compose -f ${FABRIC_DIR}/docker-compose.yaml exec cli.peer bash -c "${libcommand}; ${command}" 