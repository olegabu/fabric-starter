#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

orgs=$@
first_org=${1:-org1}
ORDERER_NAMES=${2:-${ORDERER_NAMES:-orderer:7050,raft1:7150,raft2:7250}}


: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}

info "Creating orderer service for $DOMAIN"
shopt -s nocasematch # to allow Raft, RAFT, etc

if [[ -z "$BOOTSTRAP_IP" ]]; then
    if [[ "${ORDERER_TYPE}" == "SOLO" || "${ORDERER_TYPE}" == "RAFT1" ]]; then
            WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} ./raft/0_raft-start-1-node.sh
            export ORDERER_NAMES="orderer"
    else
        if [ "${ORDERER_TYPE}" == "RAFT" ]; then
            WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} ./raft/1_raft-start-3-nodes.sh
            export ORDERER_NAMES="orderer,raft1:7150,raft2:7250"
        else
            WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} ./raft/0_raft-start-1-node.sh
            export ORDERER_NAMES="orderer"
        fi
    fi
else
    if [ "${ORDERER_TYPE}" != "SOLO" ]; then
        export ORDERER_DOMAIN="osn-${first_org}.${DOMAIN}"
        BOOTSTRAP_IP=${BOOTSTRAP_IP} WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} raft/2_raft-start-and-join-new-consenter.sh ${DOMAIN}
    fi
fi

shopt -u nocasematch

