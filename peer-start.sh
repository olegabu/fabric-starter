#!/usr/bin/env bash

peerOrg=${1:?Org is required}
ORDERER_NAME=${2:?ORDERER_NAME is required}
ORDERER_DOMAIN=${3:?ORDERER_DOMAIN is required}

source lib.sh


setMachineWorkDir ${peerOrg}
export FABRIC_STARTER_HOME=${WORK_DIR}

echo -e "\n\nStart Peer: ${peerOrg}"

connectMachine ${peerOrg}
#docker-compose ${DOCKER_COMPOSE_ARGS} down --volumes

ORG_IP=$(getMachineIp ${peerOrg})


ENROLL_SECRET_VAR="ENROLL_SECRET_${peerOrg}"
export ENROLL_SECRET=${!ENROLL_SECRET_VAR}
env|sort|grep ENROLL

docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}
docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}

#randomWait=$(( $RANDOM%10 *3 )) #TODO: introduce locking for config updates
#sleep ${randomWait}

ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN} ORDERER_NAME=${ORDERER_NAME} \
ENROLL_SECRET=${ENROLL_SECRET:-adminpw} DNS_USERNAME=${DNS_USERNAME:-${ENROLL_ID:-admin}} DNS_PASSWORD=${ENROLL_SECRET:-${ENROLL_SECRET:-adminpw}} \
BOOTSTRAP_IP=${BOOTSTRAP_IP} MY_IP=${ORG_IP} \
docker-compose ${DOCKER_COMPOSE_ARGS} up -d --force-recreate



