#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh


raftOrg=${1:?Org with running RAFT is required}
newOrg=${2:?New org is required}

: ${ORDERER_GENESIS_PROFILE:=Raft3OrdererGenesis}

connectMachine $newOrg
COMPOSE_PROJECT_NAME=${org} ORG=${org} ORDERER_NAME=raft0.${org} ORDERER_GENESIS_PROFILE=${ORDERER_GENESIS_PROFILE} ./generate-orderer.sh
COMPOSE_PROJECT_NAME=${org} docker-compose -f docker-compose-orderer.yaml up -d www.orderer --no-deps




connectMachine $raftOrg
COMPOSE_PROJECT_NAME=raft0.${org} ORDERER_NAME=raft0.${org} docker-compose -f docker-compose-orderer.yaml up -d
sleep 5
COMPOSE_PROJECT_NAME=raft1.${org} ORDERER_NAME=raft1.${org} docker-compose -f docker-compose-orderer.yaml up -d
sleep 5
COMPOSE_PROJECT_NAME=raft2.${org} ORDERER_NAME=raft2.${org} docker-compose -f docker-compose-orderer.yaml up -d
sleep 5

