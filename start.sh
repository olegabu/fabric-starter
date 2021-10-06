#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

orgs=$@
first_org=${1:-org1}

export SERVICE_CHANNEL=${SERVICE_CHANNEL:-common}

#export LDAP_ENABLED=${LDAP_ENABLED:-true}
export LDAPADMIN_HTTPS=${LDAPADMIN_HTTPS:-true}


docker_compose_args=${DOCKER_COMPOSE_ARGS:-"-f docker-compose.yaml -f docker-compose-couchdb.yaml -f https/docker-compose-generate-tls-certs.yaml -f https/docker-compose-https-ports.yaml -f docker-compose-ldap.yaml -f docker-compose-preload-images.yaml"}

: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}

unset ORG COMPOSE_PROJECT_NAME

export DOCKER_REGISTRY=${DOCKER_REGISTRY:-docker.io}
export FABRIC_VERSION=1.4.4
export FABRIC_STARTER_VERSION=${FABRIC_STARTER_VERSION:-latest}

source ${first_org}_env;
#export ENROLL_SECRET=`echo ${ENROLL_SECRET/!/\\\\!}`


if [ "$DEPLOY_VERSION" == "Hyperledger Fabric 1.4.4-GOST-34" ]; then
    set -x
    export DOCKER_REGISTRY=45.12.73.98
    export FABRIC_VERSION=gost
    export FABRIC_STARTER_VERSION=gost
    export AUTH_MODE=ADMIN
    export CRYPTO_ALGORITHM=GOST
    export SIGNATURE_HASH_FAMILY=SM3

    sudo mkdir -p /etc/docker/certs.d/${DOCKER_REGISTRY}
    openssl s_client -showcerts -connect ${DOCKER_REGISTRY}:443 </dev/null 2>/dev/null|openssl x509 -outform PEM \
        | sudo tee /etc/docker/certs.d/${DOCKER_REGISTRY}/ca.crt
    set +x
fi


#docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}
#docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}

IFS="(" read -r -a domainBootstrapIp <<< ${DOMAIN}
export DOMAIN=${domainBootstrapIp[0]}

if [ -n "${domainBootstrapIp[1]}" ];then
    IFS=")" read -r -a BOOTSTRAP_IP <<< ${domainBootstrapIp[1]}
    export BOOTSTRAP_IP
fi

echo "Using DOMAIN:${DOMAIN}, BOOTSTRAP_IP:${BOOTSTRAP_IP}, REST_API_SERVER: ${REST_API_SERVER}"

info "Creating orderer organization for $DOMAIN"

shopt -s nocasematch
if [[ -z "$BOOTSTRAP_IP" ]]; then
    if [[ "${ORDERER_TYPE}" == "SOLO" || "${ORDERER_TYPE}" == "RAFT1" ]]; then
#        WWW_PORT=${ORDERER_WWW_PORT} docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up -d
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

sleep 10


info "Create first organization ${first_org}"
echo "docker-compose ${docker_compose_args} up -d"

BOOTSTRAP_IP=${BOOTSTRAP_IP} ENROLL_SECRET="${ENROLL_SECRET}" COMPOSE_PROJECT_NAME=${first_org} docker-compose ${docker_compose_args} up -d
docker logs -f post-install.${first_org}.${DOMAIN}
