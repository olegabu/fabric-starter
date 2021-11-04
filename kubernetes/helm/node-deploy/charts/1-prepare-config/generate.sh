#!/usr/bin/env bash

source ./env
ORG=${1:-$ORG}
DOMAIN=${2:-$DOMAIN}

echo -e "\n ---------------------- GENERATE CRYPTO, GENESIS FOR: $ORG.$DOMAIN ---------------------------------- \n"

: ${RAFT_NODES_COUNT:=1}
FABRIC_STARTER_HOME=${FABRIC_STARTER_HOME:-../../../../..}

pushd $FABRIC_STARTER_HOME
./clean.sh
./raft/0_raft-start-1-node.sh '' pre-install
#docker-compose up pre-install
popd
sleep 1

rm -rf ./crypto-config/*
set -x
sudo chown -R ${USER}  ${FABRIC_STARTER_HOME}/crypto-config/
sleep 1
cp -r ${FABRIC_STARTER_HOME}/crypto-config/* ./crypto-config
set +x