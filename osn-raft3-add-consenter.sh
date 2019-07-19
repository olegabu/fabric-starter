#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh



NEWORDERER_NAME=${1}
NEWORDERER_DOMAIN=${2:-${DOMAIN}}

ORG=$raftOrg COMPOSE_PROJECT_NAME=raft0.${newOrg} EXECUTE_BY_ORDERER=1 runCLI "container-scripts/ops/raft-add-orderer.sh $NEWORDERER_NAME $NEWORDERER_DOMAIN"

exit

raftOrg=${1:?Org with running RAFT is required}
newOrg=${2:?New org is required}

: ${ORDERER_GENESIS_PROFILE:=Raft3OrdererGenesis}

connectMachine $newOrg
COMPOSE_PROJECT_NAME=${newOrg} ORG=${newOrg} ORDERER_NAME=raft0.${newOrg} ORDERER_GENESIS_PROFILE=${ORDERER_GENESIS_PROFILE} ./generate-orderer.sh
COMPOSE_PROJECT_NAME=${newOrg} docker-compose -f docker-compose-orderer.yaml up -d www.orderer --no-deps


connectMachine $raftOrg

ORG=$raftOrg COMPOSE_PROJECT_NAME=raft0.${newOrg} EXECUTE_BY_ORDERER=1 runCLI container-scripts/


COMPOSE_PROJECT_NAME=raft0.${org} ORDERER_NAME=raft0.${org} docker-compose -f docker-compose-orderer.yaml up -d
sleep 5
COMPOSE_PROJECT_NAME=raft1.${org} ORDERER_NAME=raft1.${org} docker-compose -f docker-compose-orderer.yaml up -d
sleep 5
COMPOSE_PROJECT_NAME=raft2.${org} ORDERER_NAME=raft2.${org} docker-compose -f docker-compose-orderer.yaml up -d
sleep 5



