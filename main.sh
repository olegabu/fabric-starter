#!/usr/bin/env bash

# workaround for disk resize
sleep 10
sudo lvextend /dev/rootvg/root /dev/vda3 #extend virtual group
sleep 5
sudo resize2fs /dev/rootvg/root #resize file system

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

orgs=$@
first_org=${1:-org1}

#export BOOTSTRAP_IP=${BOOTSTRAP_IP:-37.18.119.176}
#export BOOTSTRAP_IP=${BOOTSTRAP_IP:-37.18.72.69}
#export DOMAIN="${DOMAIN:-example.com}"
export SERVICE_CHANNEL=${SERVICE_CHANNEL:-common}

#export LDAP_ENABLED=${LDAP_ENABLED:-true}
export LDAPADMIN_HTTPS=${LDAPADMIN_HTTPS:-true}

docker_compose_args=${DOCKER_COMPOSE_ARGS:-"-f docker-compose.yaml -f docker-compose-couchdb.yaml -f https/docker-compose-generate-tls-certs.yaml -f https/docker-compose-https-ports.yaml -f docker-compose-ldap.yaml"}
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
export FABRIC_VERSION=1.4.4
export FABRIC_STARTER_VERSION=baas-test

if [ "$DEPLOY_VERSION" == "Hyperledger Fabric 1.4.4-GOST-34" ]; then
    set -x
    export DOCKER_REGISTRY=registry.labdlt.ru
    export FABRIC_VERSION=latest
    export FABRIC_STARTER_VERSION=baas-test
    export AUTH_MODE=ADMIN
    export CRYPTO_ALGORITHM=GOST
    export SIGNATURE_HASH_FAMILY=SM3
    export DNS_USERNAME=admin
    export DNS_PASSWORD="${ENROLL_SECRET:-adminpw}"
    set +x
fi


tmux new-session -d -s main "./deploy.sh $@"
tmux pipe-pane -o -t main 'cat > deploy.log'


exit
info "Cleaning up"
./clean.sh all

# Create orderer organization

#docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}
#docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}


source ${first_org}_env;


docker-compose -f docker-compose-deploy.yaml up -d

tmux new-session -d -s main "./test.sh ${MY_SUBSRIPTION_HOST:-6080}"
tmux pipe-pane -o -t main 'cat > test.log'



exit
info "Creating orderer organization for $DOMAIN"

shopt -s nocasematch
if [ "${ORDERER_TYPE}" == "SOLO" ]; then
    if [[ "$BOOTSTRAP_IP" == "$MY_IP" ]]; then
        WWW_PORT=${ORDERER_WWW_PORT} docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up -d
    fi
else
    WWW_PORT=${ORDERER_WWW_PORT} DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS} ./raft/1_raft-start-3-nodes.sh
fi
shopt -u nocasematch

sleep 3


info "Create first organization ${first_org}"
echo "docker-compose ${docker_compose_args} up -d"

COMPOSE_PROJECT_NAME=${first_org} docker-compose ${docker_compose_args} up -d

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
#
sleep 4
for org in "${@:2}"; do
    source ${org}_env
    orgPeer0Port=${PEER0_PORT}

    info "Adding $org to channel ${SERVICE_CHANNEL}"
    source ${first_org}_env;
    COMPOSE_PROJECT_NAME=$first_org ORG=$first_org ./channel-add-org.sh ${SERVICE_CHANNEL} ${org} ${orgPeer0Port}
done

