#!/usr/bin/env bash
set -x
source ./env
export ORG=${1:-$ORG}
export DOMAIN=${2:-$DOMAIN}
export ORDERER_DOMAIN=${3:-$DOMAIN}
set +x


echo -e "\n ---------------------- GENERATE CRYPTO, GENESIS FOR: $ORG.$DOMAIN ---------------------------------- \n"

: ${RAFT_NODES_COUNT:=1}
FABRIC_STARTER_HOME=${FABRIC_STARTER_HOME:-../../../../..}

pushd $FABRIC_STARTER_HOME
./clean.sh
./raft/0_raft-start-1-node.sh '' pre-install
#docker-compose up pre-install

docker-compose -f docker-compose-orderer.yaml run --rm -e USER_ID=${UID} --no-deps cli.orderer bash -c "set -x; chown -R \${USER_ID} /etc/hyperledger/crypto-config; set +x"

popd
sleep 1

set -x
rm -rf ./crypto-config/*

sudo chown -R ${USER}  ${FABRIC_STARTER_HOME}/crypto-config/
sleep 1
cp -r ${FABRIC_STARTER_HOME}/crypto-config/* ./crypto-config
set +x