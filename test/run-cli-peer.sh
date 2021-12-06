#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

compose_org=${1}
domain=${2}
command=${@:3}

libcommand='source container-scripts/lib/container-lib.sh 2>/dev/null'

COMPOSE_PROJECT_NAME=${compose_org} docker-compose -f ${FABRIC_DIR}/docker-compose.yaml exec -T cli.peer bash -c "${libcommand}; ${command}"
