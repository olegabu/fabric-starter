#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
#source $BASEDIR/../lib.sh
#source ../lib.sh 2>/dev/null # for IDE code completion

ORDERER_ADDRESSES=${@:?Orderer addresses are required}

: ${DOMAIN:=example.com}
: ${ORDERER_DOMAIN:=${DOMAIN}}
: ${ORDERER_NAME:=orderer}
: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml"}

export DOMAIN ORDERER_NAME ORDERER_DOMAIN

for ordererAddr in ${ORDERER_ADDRESSES}; do
    IFS=':' read -r -a ordererHost <<< ${ordererAddr}
    ordererPort=${ordererHost[1]:-80}
    ordererHost=${ordererHost[0]}
    IFS='.' read -r -a addrParts <<< ${ordererHost}
    ordererName=${addrParts[0]}
    remoteOrdererDomain=${ordererHost:((${#ordererName}+1))}
    echo "Download: ${ordererName}.${remoteOrdererDomain}:${ordererPort}"
    COMPOSE_PROJECT_NAME=TLS docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --rm --no-deps cli.orderer wget --verbose -N --directory-prefix crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/msp/${ordererName}.${remoteOrdererDomain}/tls http://${ordererHost}/msp/${ordererHost}/tls/server.crt
done

