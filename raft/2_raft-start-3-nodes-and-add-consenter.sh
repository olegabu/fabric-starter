#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion


usageMsg="ORG=org ORDERER_NAME_PREFIX=<orderer name prefix> $0 <new-consenter-name> <new-consenter-domain>"
exampleMsg="ORG=org1 ORDERER_NAME_PREFIX=raft0 $0"

#IFS=
#NEWCONSENTER_NAME=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
#NEWCONSENTER_DOMAIN=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
#chaincodeLang=${3:?Chaincode lang must be specified}
#chaincodeVersion=${4:?Chaincode version must be specified}
#chaincodePackageName=${5:?Chaincode PackageName must be specified}

: ${ORDERER_NAME_PREFIX:=raft}
: ${ORG:=org1}
: ${DOMAIN:=example.com}

DOMAIN=${ORG}.${DOMAIN} ORDERER_GENESIS_PROFILE=Raft3OrdererGenesis COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}0.${ORG} ORDERER_NAME=${ORDERER_NAME_PREFIX}0 docker-compose -f docker-compose-orderer.yaml up -d orderer
sleep 5
DOMAIN=${ORG}.${DOMAIN} COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}1.${ORG} ORDERER_NAME=${ORDERER_NAME_PREFIX}1 docker-compose -f docker-compose-orderer.yaml up -d orderer
sleep 5
DOMAIN=${ORG}.${DOMAIN} COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}2.${ORG} ORDERER_NAME=${ORDERER_NAME_PREFIX}2 docker-compose -f docker-compose-orderer.yaml up -d orderer
sleep 5


#COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}0.${ORG} ORDERER_NAME=${ORDERER_NAME_PREFIX}0 $BASEDIR/raft-add-consenter.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN}

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



