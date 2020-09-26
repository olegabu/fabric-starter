#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

orgs=$@
first_org=${1:-org1}

#export LDAP_ENABLED=${LDAP_ENABLED:-true}
export LDAPADMIN_HTTPS=${LDAPADMIN_HTTPS:-true}

docker_compose_args=${DOCKER_COMPOSE_ARGS:-"-f docker-compose.yaml -f docker-compose-couchdb.yaml -f https/docker-compose-generate-tls-certs.yaml -f https/docker-compose-https-ports.yaml -f docker-compose-ldap.yaml"}
# -f environments/dev/docker-compose-debug.yaml -f https/docker-compose-generate-tls-certs-debug.yaml
: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}


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


tmux new-session -d -s main "set -x; ./disk_resize.sh; set +x; sleep 10; ./deploy.sh $@"
tmux pipe-pane -o -t main 'cat > deploy.log'


