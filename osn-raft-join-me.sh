#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh

REMOTE_ORDERER_ADDR=${1:?Remote addr is requried}
EXECUTE_BY_ORDERER=1 runCLI "container-scripts/ops/raft-join-me.sh $REMOTE_ORDERER_ADDR"

COMPOSE_PROJECT_NAME=raft0.org2 docker-compose -f docker-compose-orderer.yaml up -d --force-recreate orderer
