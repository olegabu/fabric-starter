#!/usr/bin/env /bin/bash

ORG=${1:-${ORG:-org1}}
REMOTE_ORDERER_DOMAIN=${2:-${DOMAIN:-example.com}}
ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN}
ORDERER_WWW_PORT=${ORDERER_WWW_PORT:-79}

ORDERER_NAMES=${3:-${ORDERER_NAMES:-orderer:${ORDERER_GENERAL_LISTENPORT:-7050},raft1:7150,raft2:7250}}
: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}
export CHANNEL_AUTO_JOIN=${CHANNEL_AUTO_JOIN-${DNS_CHANNEL:-common}}

function main() {
    echo "ORDERER_NAMES=${ORDERER_NAMES}"
    parseOrdererNames

    shopt -s nocasematch # to allow Raft, RAFT, etc

    if [[ -z "$BOOTSTRAP_IP" ]]; then
        info "Creating orderer service for ${ORDERER_DOMAIN}, of type ${ORDERER_TYPE}"
        if [[ "${ORDERER_TYPE}" == "SOLO" || "${ORDERER_TYPE}" == "RAFT1" ]]; then
                set -x
                WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} ./raft/0_raft-start-1-node.sh
                returnCode=$?
                set +x
                export ORDERER_NAMES=${ORDERER_NAME:-${ORDERER_NAME_1:-"orderer"}}
        else
                set -x
                WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} ./raft/1_raft-start-3-nodes.sh
                returnCode=$?
                set +x
                export ORDERER_NAMES=${ORDERER_NAMES}
        fi
    else
        if [ "${ORDERER_TYPE}" == "RAFT" ]; then
            if [[ "${REMOTE_ORDERER_DOMAIN}" == "${ORDERER_DOMAIN}" ]]; then
                info "BOOTSTRAP_ORDERER_DOMAIN($BOOTSTRAP_ORDERER_DOMAIN) (or BOOTSTRAP_DOMAIN($BOOTSTRAP_DOMAIN)) should be different than ORDERER_DOMAIN($ORDERER_DOMAIN) for RAFT service"
                echo "Exiting"
                exit 1;
            fi

            export ORDERER_DOMAIN=${ORDERER_DOMAIN:-"osn-${ORG}.${DOMAIN}"}
            info "Creating orderer service for ${ORDERER_DOMAIN}, of type ${ORDERER_TYPE}"
            set -x
#            if [ ${CHANNEL_AUTO_JOIN} ]; then
                BOOTSTRAP_IP=${BOOTSTRAP_IP} WWW_PORT=${ORDERER_WWW_PORT}  DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} raft/2_raft-start-and-join-new-consenter.sh ${REMOTE_ORDERER_DOMAIN}
#            else
#                progressFile="crypto-config/orderer-prepared-with-${REMOTE_ORDERER_DOMAIN}.prepared"
#                if [ ! -f "${progressFile}" ]; then
#                    BOOTSTRAP_IP=${BOOTSTRAP_IP} WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} raft/2_raft-prepare-new-consenter.sh ${REMOTE_ORDERER_DOMAIN}
#                    [ "$?" -eq 0 ] && touch "${progressFile}" # set mark that prepare stage has processed
#                else
#                    # set hosts dns info
#                    COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --rm --no-deps cli.orderer \
#                        bash -c "echo -e '\n${BOOTSTRAP_ORDERER_IP:-$BOOTSTRAP_IP} ${BOOTSTRAP_ORDERER_NAME:-orderer}.${REMOTE_ORDERER_DOMAIN} www.${REMOTE_ORDERER_DOMAIN}\n' >> /etc/hosts ; \
#                                 echo -e '${BOOTSTRAP_RAFT1_IP:-$BOOTSTRAP_IP} ${BOOTSTRAP_RAFT1_NAME:-raft1}.${REMOTE_ORDERER_DOMAIN}\n' >> /etc/hosts ; \
#                                 echo -e '${BOOTSTRAP_RAFT2_IP:-$BOOTSTRAP_IP} ${BOOTSTRAP_RAFT2_NAME:-raft2}.${REMOTE_ORDERER_DOMAIN}\n' >> /etc/hosts"
#                fi
#            fi
            returnCode=$?
            set +x
        fi
    fi
    shopt -u nocasematch

    return ${returnCode}
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
    [ `uname` == 'Darwin' ] && ordererConf=($ordererConf) # TODO ???
    local ordererName=${ordererConf[0]}
    local ordererPort=${ordererConf[1]}
    export ORDERER_NAME_${index}=${ordererName}
    export RAFT${index}_PORT=${ordererPort}
    [ $index -eq 0 ] && export ORDERER_GENERAL_LISTENPORT=${ordererPort}
    echo "Parsed orderer: ORDERER_NAME_${index}:${ordererName}, RAFT${index}_PORT:${ordererPort}"
}

main
