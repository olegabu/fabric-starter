#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

export ARGS_PASSED=("$@")
source ../libs/libs.sh

checkArgsPassed

orgs=${@}
DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}

echo "Deploing network for [${DEPLOYMENT_TARGET}] target. Domain: $DOMAIN, Orgs: ${orgs[@]}"
echo "\${DOCKER_REGISTRY} is set to: [${DOCKER_REGISTRY}]"
echo "\${MULTIHOST} is set to: [${MULTIHOST}]"
sleep 2

case "${DEPLOYMENT_TARGET}" in
    
    local)
        unset MULTIHOST
        pushd ../../ >/dev/null
        ./network-create-local.sh ${@}
        popd >/dev/null
    ;;
    raft-local)
        unset MULTIHOST
        pushd ../../ >/dev/null
        api_port=${API_PORT:-4000}
        www_port=${WWW_PORT:-80}
        ca_port=${CA_PORT:-7054}
        orderer_port=${ORDERER_PORT:-7050}
        orderer_www_port=${ORDERER_WWW_PORT:-79}
        peer0_port=${PEER0_PORT:-7051}
        ldap_http=${LDAP_PORT_HTTP:-6080}
        ldap_https=${LDAP_PORT_HTTPS:-6443}
        custom_port=${CUSTOM_PORT}
        enroll_secret=${ENROLL_SECRET:-adminpw}
        first_org=${1}
        first_api_port=${api_port}
        first_www_orderer_port=${orderer_www_port}
        MY_IP=$(getOrgIp) \
        FIRST_ORG=${first_org} ORG=${first_org} ENROLL_SECRET=${enroll_secret} API_PORT=${api_port} WWW_PORT=${www_port} \
        CA_PORT=${ca_port} ORDERER_PORT=${orderer_port} ORDERER_WWW_PORT=${orderer_www_port} PEER0_PORT=${peer0_port} \
        LDAP_PORT_HTTP=${ldap_http} LDAP_PORT_HTTPS=${ldap_https} CUSTOM_PORT=${custom_port} \
        envsubst <./test/resources/config/org1 > ${1}_env
        for org in ${@:2}; do
          api_port=$((api_port + 1))
          www_port=$((www_port + 1))
          ca_port=$((ca_port + 1))
          orderer_port=$((orderer_port + 1000))
          orderer_www_port=$((orderer_www_port - 1))
          peer0_port=$((peer0_port + 1000))
          ldap_http=$((ldap_http + 100))
          ldap_https=$((ldap_https + 100))
          custom_port=$((custom_port + 1))
          MY_IP=$(getOrgIp) FIRST_ORG=${first_org} FIRST_API_PORT=${first_api_port} ENROLL_SECRET=${enroll_secret} \
          FIRST_WWW_ORDERER_PORT=${first_www_orderer_port} ORG=${org} API_PORT=${api_port} WWW_PORT=${www_port} \
          CA_PORT=${ca_port} ORDERER_PORT=${orderer_port} ORDERER_WWW_PORT=${orderer_www_port} PEER0_PORT=${peer0_port} \
          LDAP_PORT_HTTP=${ldap_http} LDAP_PORT_HTTPS=${ldap_https} CUSTOM_PORT=${custom_port} \
          envsubst <./test/resources/config/org2 > "${org}_env"
        done
        ./clean.sh all
        ./deploy.sh ${@}
        popd >/dev/null
    ;;
    vbox)   #dmachine
        pushd ../../ >/dev/null
#       ./network-docker-machine-create.sh  ${@}
        ./network-create.sh  ${@}

        popd >/dev/null
    ;;
    *)
        echo "Wrong target [${DEPLOYMENT_TARGET}]"
    ;;
esac
