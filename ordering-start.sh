#!/usr/bin/env /bin/bash

ORG=${1:-${ORG:-org1}}
DOMAIN=${2:-${DOMAIN:-example.com}}
ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN}
REMOTE_ORDERER_DOMAIN=${REMOTE_ORDERER_DOMAIN:-${DOMAIN}}
ORDERER_WWW_PORT=${ORDERER_WWW_PORT:-79}
ORDERER_NAMES=${3:-${ORDERER_NAMES:-orderer:${ORDERER_GENERAL_LISTENPORT:-7050},raft1:7150,raft2:7250}}
: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}


function main() {
    echo "ORDERER_NAMES=${ORDERER_NAMES}"
    parseOrdererNames

    info "Creating orderer service for ${ORDERER_DOMAIN}, of type ${ORDERER_TYPE}"
    shopt -s nocasematch # to allow Raft, RAFT, etc

    if [[ -z "$BOOTSTRAP_IP" ]]; then
        if [[ "${ORDERER_TYPE}" == "SOLO" || "${ORDERER_TYPE}" == "RAFT1" ]]; then
                set -x
                WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} ./raft/0_raft-start-1-node.sh
                set +x
                export ORDERER_NAMES=${ORDERER_NAME:-${ORDERER_NAME_1:-"orderer"}}
        else
                set -x
                WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} ./raft/1_raft-start-3-nodes.sh
                set +x
                export ORDERER_NAMES=${ORDERER_NAMES}
        fi
    else
        if [ "${ORDERER_TYPE}" != "SOLO" ]; then
            set -x
            export ORDERER_DOMAIN=${ORDERER_DOMAIN:-"osn-${ORG}.${DOMAIN}"}
            BOOTSTRAP_IP=${BOOTSTRAP_IP} WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} raft/2_raft-start-and-join-new-consenter.sh ${REMOTE_ORDERER_DOMAIN}
            set +x
        fi
    fi
    shopt -u nocasematch
}

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

function parseOrdererNames() {
    echo -e "\n\nUsing ORDERER_NAMES: ${ORDERER_NAMES}\n\n"
    local ordererNames
    IFS="," read -r -a ordererNames <<< ${ORDERER_NAMES}
    ordererNames=($ordererNames)
    local i
    for i in ${!ordererNames[@]}; do
        parseOrdererName_Port $i ${ordererNames[$i]}
    done
}

function parseOrdererName_Port() {
    local index=${1:?Index of orderer name is required}
    local ordererName_Port=${2:?ordererName_Port(name:port) is required}

    local ordererConf
    IFS=':' read -r -a ordererConf <<< ${ordererName_Port};
    ordererConf=($ordererConf)
    local ordererName=${ordererConf[0]}
    local ordererPort=${ordererConf[1]}

    export ORDERER_NAME_${index}=${ordererName}
    export RAFT${index}_PORT=${ordererPort}
    [ $index -eq 0 ] && export ORDERER_GENERAL_LISTENPORT=${ordererPort}
    echo "Parsed orderer: ORDERER_NAME_${index}:${ordererName}, RAFT${index}_PORT:${ordererPort}"
}

main
