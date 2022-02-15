#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
#source $BASEDIR/env.sh

REMOTE_ORDERER_DOMAIN=${1:?Remote orderer domain is requried}

usageMsg="$0 <BOOTSTRAP_ORDERER_DOMAIN>"
exampleMsg="$0 osn1-example.com"

: ${BOOTSTRAP_IP}
: ${BOOTSTRAP_EXTERNAL_PORT:=${API_PORT:-4000}}
: ${DOMAIN:=example.com}
: ${ORG:=org1}
: ${ORDERER_NAME:=orderer}
: ${ORDERER_NAME_PREFIX:=raft}
: ${ORDERER_DOMAIN:=$DOMAIN}
: ${ORDERER_GENERAL_LISTENPORT:=7050}
: ${BOOTSTRAP_SERVICE_URL:=https}
: ${ORDERER_WWW_PORT:=79}

export DOMAIN ORDERER_NAME ORDERER_DOMAIN ORDERER_GENERAL_LISTENPORT=$ORDERER_GENERAL_LISTENPORT WWW_PORT

export DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS:-"-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}
export COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN}

ORDERER_PROFILE=Raft docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d www.orderer pre-install

#env|sort

progressFile="crypto-config/orderer-prepared-with-${REMOTE_ORDERER_DOMAIN}.prepared"

if [[ ${CHANNEL_AUTO_JOIN} ]]; then
    docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --rm --no-deps --name raft_request cli.orderer \
      bash -c "set -x; container-scripts/wait-port.sh ${MY_IP} ${ORDERER_WWW_PORT}; curl -k  --connect-timeout 30 --max-time 240 --retry 0 \
      ${BOOTSTRAP_SERVICE_URL}://${BOOTSTRAP_IP}:${BOOTSTRAP_EXTERNAL_PORT}/integration/service/raft -H 'Content-Type: application/json' \
        -d '{\"ordererName\":\"${ORDERER_NAME}\",\"domain\":\"${ORDERER_DOMAIN}\",\"ordererPort\":\"${ORDERER_GENERAL_LISTENPORT}\",\
             \"wwwPort\":\"${WWW_PORT}\",\"ordererIp\":\"${MY_IP}\",\"orgId\":\"${ORG}\"}' --output crypto-config/configtx/${ORDERER_DOMAIN}/genesis.pb; set +x "
    echo
    echo curl completed
    sleep 2
    touch "${progressFile}" # set mark that prepare stage has processed
else
    echo -e "\nCHANNEL_AUTO_JOIN is set to false. Skipping auto-connect to Raft service"
fi

#docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer \
#  bash -c "echo -e '${REMOTE_IP}\t www.${REMOTE_DOMAIN} orderer.${REMOTE_DOMAIN} ${ORDERER_NAME_2:-raft1}.${REMOTE_DOMAIN} ${ORDERER_NAME_3:-raft2}.${REMOTE_DOMAIN}' >> /etc/hosts"

if [[ -f "${progressFile}" ]]; then
    echo -e "\nFound stage file ${progressFile}. Continue starting orderer\n"
    raft/4_raft-start-consenter.sh ${REMOTE_ORDERER_DOMAIN} www.${REMOTE_ORDERER_DOMAIN}:${WWW_PORT} ${BOOTSTRAP_IP}
else
  echo -e "\nSkip starting orderer. Waiting for manual integration to raft service. Creating stage file ${progressFile}.\n"
  touch "${progressFile}" # set mark that prepare stage has processed
fi



#raft/4_raft-start-consenter.sh ${REMOTE_DOMAIN} www.${REMOTE_DOMAIN}:${WWW_PORT} ${BOOTSTRAP_IP}


