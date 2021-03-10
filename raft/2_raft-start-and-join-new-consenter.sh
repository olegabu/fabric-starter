#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
#source $BASEDIR/env.sh

REMOTE_DOMAIN=${1:?Remote orderer domain is requried}

usageMsg="$0 <BOOTSTRAP_ORDERER_DOMAIN>"
exampleMsg="$0 osn1-example.com"

: ${BOOTSTRAP_IP}
: ${BOOTSTRAP_EXTERNAL_PORT:=${API_PORT:-4000}}
: ${DOMAIN:=example.com}
: ${ORG:=org1}
: ${ORDERER_NAME:=orderer}
: ${ORDERER_NAME_PREFIX:=raft}
: ${ORDERER_DOMAIN:=$DOMAIN}
: ${ORDERER_GENERAL_LISTENPORT:=${ORDERER_GENERAL_LISTENPORT:-7050}}
: ${BOOTSTRAP_SERVICE_URL:=https}
: ${ORDERER_WWW_PORT:=79}

export DOMAIN ORDERER_NAME ORDERER_DOMAIN ORDERER_GENERAL_LISTENPORT WWW_PORT

export DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS:-"-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}
export COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN}
ORDERER_PROFILE=Raft docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d www.orderer pre-install

#env|sort
docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps --name raft_request cli.orderer \
  bash -c "set -x; container-scripts/wait-port.sh ${MY_IP} ${ORDERER_WWW_PORT}; curl -i -k  --connect-timeout 30 --max-time 240 --retry 0 \
  ${BOOTSTRAP_SERVICE_URL}://${BOOTSTRAP_IP}:${BOOTSTRAP_EXTERNAL_PORT}/integration/service/raft -H 'Content-Type: application/json' \
    -d '{\"ordererName\":\"${ORDERER_NAME}\",\"domain\":\"${ORDERER_DOMAIN}\",\"ordererPort\":\"${ORDERER_GENERAL_LISTENPORT}\",\
         \"wwwPort\":\"${WWW_PORT}\",\"ordererIp\":\"${MY_IP}\",\"orgId\":\"${ORG}\"}'; set +x "


set -x
docker rm -f raft_request
set +x


echo
echo curl completed
sleep 2


raft/4_raft-start-consenter.sh ${REMOTE_DOMAIN} www.${REMOTE_DOMAIN}:${WWW_PORT} ${BOOTSTRAP_IP}

#docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer \
#  bash -c "echo -e '${REMOTE_IP}\t www.${REMOTE_DOMAIN} orderer.${REMOTE_DOMAIN} ${ORDERER_NAME_2:-raft1}.${REMOTE_DOMAIN} ${ORDERER_NAME_3:-raft2}.${REMOTE_DOMAIN}' >> /etc/hosts"

