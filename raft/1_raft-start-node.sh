#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib/util/util.sh
source ../lib/util/util.sh 2>/dev/null # for IDE code completion


usageMsg="ORG=<org name> ORDERER_NAME=<orderer instance name> $0"
exampleMsg="ORG=org1 ORDERER_NAME=raft0 $0"

#IFS=
#chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
#chaincodePath=${2:?Chaincode path must be specified}
#chaincodeLang=${3:?Chaincode lang must be specified}
#chaincodeVersion=${4:?Chaincode version must be specified}
#chaincodePackageName=${5:?Chaincode PackageName must be specified}

: ${ORG:=org1}
: ${DOMAIN:=example.com}

DOMAIN=${ORG}.${DOMAIN} COMPOSE_PROJECT_NAME=${ORG} ORDERER_GENESIS_PROFILE=RaftOrdererGenesis docker-compose -f docker-compose-orderer.yaml up -d orderer

sleep 2

DOMAIN=${DOMAIN} COMPOSE_PROJECT_NAME=${ORG} docker-compose up -d