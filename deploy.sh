#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

orgs=$@
first_org=${1:-org1}
DEV_MODE=${DEV_MODE}
AGENT_MODE=${AGENT_MODE}
[ -z "${DEV_MODE}" ] && HTTPS_MODE=${HTTPS_MODE:-1}
[ -z "${DEV_MODE}" ] && LDAP_ENABLED=${LDAP_ENABLED:-1}

export ORG=''
if [ -z "${AGENT_MODE}" ]; then
   source ${first_org}_env;
   export ORG=${ORG:-${first_org:-org1}}
   export DOMAIN=${DOMAIN:-example.com}
fi

export ORDERER_WWW_PORT=${ORDERER_WWW_PORT:-79}
export SERVICE_CHANNEL=${SERVICE_CHANNEL:-common}


docker_compose_args=${DOCKER_COMPOSE_ARGS:-"-f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-ldap.yaml -f docker-compose-preload-images.yaml"}
if [ -n "${HTTPS_MODE}" ]; then # https mode
    export LDAPADMIN_HTTPS=${LDAPADMIN_HTTPS:-true}
    export DOCKER_COMPOSE_EXTRA_ARGS=${DOCKER_COMPOSE_EXTRA_ARGS:-"-f https/docker-compose-https-ports.yaml"}
else # http mode
    export LDAPADMIN_HTTPS=${LDAPADMIN_HTTPS:-false}
    export DOCKER_COMPOSE_EXTRA_ARGS=${DOCKER_COMPOSE_EXTRA_ARGS:-"-f docker-compose-dev.yaml"}
fi


: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}

#virtalbox:
# export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-ports.yaml"
# export DOCKER_REGISTRY=192.168.99.1:5000
# to orgX_env
# export BOOTSTRAP_IP=192.168.99.116
# export MY_IP=`docker-machine ip ${ORG}.${DOMAIN}`
# export FABRIC_STARTER_HOME=`docker-machine ssh ${ORG}.${DOMAIN} pwd`

export DOCKER_REGISTRY=${DOCKER_REGISTRY:-docker.io}
export FABRIC_VERSION=${FABRIC_VERSION:-1.4.4}
export FABRIC_STARTER_VERSION=${FABRIC_STARTER_VERSION:-baas-test}


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

info "Cleaning up"
./clean.sh all


if [ -z "${DEV_MODE}" ]; then
    docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}
    docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}
    #docker pull ${DOCKER_REGISTRY:-docker.io}/vrreality/deployer:${FABRIC_STARTER_VERSION:-latest}
fi

export REST_API_SERVER="http://api.${ORG:-org1}.${DOMAIN:-example.com}:3000"
echo "Using DOMAIN:${DOMAIN}, BOOTSTRAP_IP:${BOOTSTRAP_IP}, REST_API_SERVER: ${REST_API_SERVER}"

#BOOTSTRAP_IP=${BOOTSTRAP_IP} docker-compose -f docker-compose-deploy.yaml up -d
#nc -l ${MY_SUBSRIPTION_PORT:-6080} &

#./wait-port.sh ${MY_IP} ${WWW_PORT} # wait for external availability in clouds

export COMPOSE_PROJECT_NAME=${ORG:-org1} #TODO: try to avoid pre-install container in AGENT_MODE

if [ -z "$AGENT_MODE" ]; then
    info "Start ordering service"
    ORDERER_WWW_PORT=${ORDERER_WWW_PORT} ./ordering-start.sh $ORG $DOMAIN
    sleep 5
fi

info "Create first organization ${ORG}"
set -x
BOOTSTRAP_IP=${BOOTSTRAP_IP} ENROLL_SECRET="${ENROLL_SECRET:-adminpw}"  docker-compose ${docker_compose_args} ${DOCKER_COMPOSE_EXTRA_ARGS} \
    up -d ${AGENT_MODE:+api www.peer}
#    up -d ${AGENT_MODE:+pre-install ca api ldap-service ldapadmin www.peer}
set +x
if [ -z "${AGENT_MODE}" ]; then
    docker logs -f post-install.${ORG}.${DOMAIN}
fi

if [[ -n "$2" ]]; then
    echo -e "\nWait post-install.${first_org}.${DOMAIN} to complete"
    docker wait post-install.${first_org}.${DOMAIN} > /dev/null
fi

for org in ${@:2}; do
    source ${org}_env
    info "      Creating member organization $ORG with api $API_PORT"
    set -x
    COMPOSE_PROJECT_NAME=${org} docker-compose ${docker_compose_args} ${DOCKER_COMPOSE_EXTRA_ARGS} up -d
    set +x
done

sleep 4
for org in "${@:2}"; do
    source ${org}_env
    currOrgPeer0Port=${PEER0_PORT}
    currOrg=${ORG}

    info "Adding $currOrg to channel ${SERVICE_CHANNEL}"
    source ${first_org}_env;
    COMPOSE_PROJECT_NAME=$ORG  ./channel-add-org.sh ${SERVICE_CHANNEL} ${currOrg} ${currOrgPeer0Port}
done

docker ps
