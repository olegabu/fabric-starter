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


./container-scripts/wait-port.sh docker.io 443

tmux new-session -d -s main "./disk_resize.sh; ./deploy.sh $@"
tmux pipe-pane -o -t main 'cat > deploy.log'


