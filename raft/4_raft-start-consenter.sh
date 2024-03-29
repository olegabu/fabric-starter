#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/env.sh

REMOTE_ORDERER_DOMAIN=${1:?Remote domain is requried}
REMOTE_WWW_ADDR=${2:?Remote www addr is requried}
REMOTE_IP=${3:?Remote ip is requried}

: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=orderer}
: ${ORDERER_DOMAIN:=${DOMAIN}}
: ${ORDERER_GENERAL_LISTENPORT:=7050}
: ${ORDERER_NAME_PREFIX:=raft}
set -x
export DOMAIN ORDERER_NAME ORDERER_DOMAIN ORDERER_GENERAL_LISTENPORT
echo $DOMAIN $ORDERER_NAME $ORDERER_DOMAIN $ORDERER_GENERAL_LISTENPORT $REMOTE_ORDERER_DOMAIN
export COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} EXECUTE_BY_ORDERER=1

#docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --rm --no-deps cli.orderer \
#  bash -c "echo -e '${REMOTE_IP}\t www.${REMOTE_DOMAIN} orderer.${REMOTE_DOMAIN} ${ORDERER_NAME_1:-raft1}.${REMOTE_DOMAIN} ${ORDERER_NAME_2:-raft2}.${REMOTE_DOMAIN}' >> /etc/hosts"

docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --rm --no-deps cli.orderer \
    bash -c "echo -e '\n${BOOTSTRAP_ORDERER_IP:-$REMOTE_IP} ${BOOTSTRAP_ORDERER_NAME:-orderer}.${REMOTE_ORDERER_DOMAIN} www.${REMOTE_ORDERER_DOMAIN}\n' >> /etc/hosts ; sleep 1; \
             echo -e '${BOOTSTRAP_RAFT1_IP:-$REMOTE_IP} ${BOOTSTRAP_RAFT1_NAME:-raft1}.${REMOTE_ORDERER_DOMAIN}\n' >> /etc/hosts ; sleep 1; \
             echo -e '${BOOTSTRAP_RAFT2_IP:-$REMOTE_IP} ${BOOTSTRAP_RAFT2_NAME:-raft2}.${REMOTE_ORDERER_DOMAIN}\n' >> /etc/hosts"


#docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} \
#  run --rm --no-deps cli.orderer container-scripts/ops/download-remote-config-block.sh $REMOTE_WWW_ADDR
#sleep 1

echo "Start orderer ${ORDERER_NAME}.${ORDERER_DOMAIN} with new genesis"
docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer cli.orderer #www.orderer

set +x
