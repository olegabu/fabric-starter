#!/usr/bin/env bash

source ./env
export ORG=${1:-$ORG}
export DOMAIN=${2:-$DOMAIN}
export ORDERER_DOMAIN=${3:-$DOMAIN}

echo -e "\n ---------------------- GENERATE CRYPTO, GENESIS FOR: $ORG.$DOMAIN ---------------------------------- \n"

: ${RAFT_NODES_COUNT:=1}
FABRIC_STARTER_HOME=${FABRIC_STARTER_HOME:-../../../../..}

pushd $FABRIC_STARTER_HOME
    ./clean.sh
    ./raft/0_raft-start-1-node.sh '' pre-install
    #docker-compose up pre-install
    USER_ID=${UID}  docker-compose -f docker-compose-orderer.yaml run --rm -e USER_ID=${UID} --no-deps cli.orderer bash -c "set -x; chown -R \${USER_ID} /etc/hyperledger/crypto-config; set +x"
popd

set -x
    rm -rf ./crypto-config/*
    sleep 5
    cp -r ${FABRIC_STARTER_HOME}/crypto-config/* ./crypto-config
set +x