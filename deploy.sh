#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

orgs=$@
first_org=${1:-org1}

export SERVICE_CHANNEL=${SERVICE_CHANNEL:-common}

#export LDAP_ENABLED=${LDAP_ENABLED:-true}
export LDAPADMIN_HTTPS=${LDAPADMIN_HTTPS:-true}

export FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY:-olegabu}

docker_compose_args=${DOCKER_COMPOSE_ARGS:-"-f docker-compose.yaml -f docker-compose-couchdb.yaml -f https/docker-compose-generate-tls-certs.yaml -f https/docker-compose-https-ports.yaml -f docker-compose-ldap.yaml -f docker-compose-preload-images.yaml"}
#docker_compose_args=${DOCKER_COMPOSE_ARGS:-"-f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-ports.yaml "}

# -f environments/dev/docker-compose-debug.yaml -f https/docker-compose-generate-tls-certs-debug.yaml
: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}

#virtalbox:
# export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-ports.yaml"
# export DOCKER_REGISTRY=192.168.99.1:5000
# to orgX_env
# export BOOTSTRAP_IP=192.168.99.116
# export MY_IP=`docker-machine ip ${ORG}.${DOMAIN}`
# export FABRIC_STARTER_HOME=`docker-machine ssh ${ORG}.${DOMAIN} pwd`


unset ORG COMPOSE_PROJECT_NAME

export DOCKER_REGISTRY=${DOCKER_REGISTRY:-docker.io}
export FABRIC_STARTER_VERSION=${FABRIC_STARTER_VERSION:-latest}

source ${first_org}_env
#export ENROLL_SECRET=`echo ${ENROLL_SECRET/!/\\\\!}`


if [ -z $SKIP_CLEANING ]; then
 info "Cleaning up"
./clean.sh all
fi
# Create orderer organization

docker pull ${DOCKER_REGISTRY:-docker.io}/${FABRIC_STARTER_REPOSITORY}/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}
docker pull ${DOCKER_REGISTRY:-docker.io}/${FABRIC_STARTER_REPOSITORY}/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}
#docker pull ${DOCKER_REGISTRY:-docker.io}/vrreality/deployer:${FABRIC_STARTER_VERSION:-latest}


IFS="(" read -r -a domainBootstrapIp <<< ${DOMAIN}
export DOMAIN=${domainBootstrapIp[0]}

if [ -n "${domainBootstrapIp[1]}" ];then
    IFS=")" read -r -a BOOTSTRAP_IP <<< ${domainBootstrapIp[1]}
    export BOOTSTRAP_IP
fi

export REST_API_SERVER="http://api.${ORG:-org1}.${DOMAIN:-example.com}:3000"
echo "Using DOMAIN:${DOMAIN}, BOOTSTRAP_IP:${BOOTSTRAP_IP}, REST_API_SERVER: ${REST_API_SERVER}"

#BOOTSTRAP_IP=${BOOTSTRAP_IP} docker-compose -f docker-compose-deploy.yaml up -d
#nc -l ${MY_SUBSRIPTION_PORT:-6080} &

#./wait-port.sh ${MY_IP} ${WWW_PORT} # wait for external availability in clouds

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

if [[ -n "$2" ]]; then
    echo -e "\nWait post-install.${first_org}.${DOMAIN} to complete"
    docker wait post-install.${first_org}.${DOMAIN} > /dev/null
fi

for org in ${@:2}; do
    source ${org}_env
    info "      Creating member organization $ORG with api $API_PORT"
    echo "docker-compose ${docker_compose_args} up -d"
    COMPOSE_PROJECT_NAME=${org} docker-compose ${docker_compose_args} up -d
done
