#!/usr/bin/env bash

source ./env
: ${ORG:=$1}
: ${RAFT_NODES_COUNT:=1}
FABRIC_STARTER_HOME=${FABRIC_STARTER_HOME:-../../../../../}

pushd $FABRIC_STARTER_HOME
./clean.sh
./raft/0_raft-start-1-node.sh '' pre-install
docker-compose up pre-install
popd

rm -rf ./crypto-config/*
set -x
cp -r ${FABRIC_STARTER_HOME}/crypto-config/* ./crypto-config
set +x