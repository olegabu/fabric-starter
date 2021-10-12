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

export DOCKER_C_ARGS="-f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-ports.yaml "

case "${DEPLOYMENT_TARGET}" in
    
    local)
        unset MULTIHOST
        pushd ../../ >/dev/null
        #TODO ports
        ORG1=${1} ORG2=${2} DOMAIN=${DOMAIN} \
        MY_IP1='172.17.0.1' MY_IP2='172.17.0.1' \
        BOOTSTRAP_SERVICE_URL='http' \
        FABRIC_STARTER_HOME='' \

        ./deploy.sh ${ORG1} ${ORG2}
        popd >/dev/null
    ;;
    vbox)   #dmachine
        pushd ../../ >/dev/null

#       ./network-docker-machine-create.sh  ${@}
        #TODO ports
        TEST_ORG1=${1}
        TEST_ORG2=${2}

        DOCKER_COMPOSE_ARGS=${DOCKER_C_ARGS} \
        ORG1=${TEST_ORG1} ORG2=${TEST_ORG2} DOMAIN=${DOMAIN} \
        MY_IP1=$(getOrgIp ${TEST_ORG1}) \
        MY_IP2=$(getOrgIp ${TEST_ORG2}) \
        API_PORT=4000 \
        WWW_PORT=80 \
        FABRIC_STARTER_HOME=$(docker-machine ssh ${TEST_ORG1}.${DOMAIN} pwd) \
        BOOTSTRAP_IP=$(getOrgIp ${TEST_ORG1}) BOOTSTRAP_SERVICE_URL='http' \
        envsubst < test/resources/org_env/org1_env > "${TEST_ORG1}"_env

        DOCKER_COMPOSE_ARGS=${DOCKER_C_ARGS} \
        ORG1=${TEST_ORG1} ORG2=${TEST_ORG2} DOMAIN=${DOMAIN} \
        MY_IP1=$(getOrgIp ${TEST_ORG1}) \
        MY_IP2=$(getOrgIp ${TEST_ORG2}) \
        API_PORT=4000 \
        WWW_PORT=80 \
        FABRIC_STARTER_HOME=$(docker-machine ssh ${TEST_ORG2}.${DOMAIN} pwd) \
        BOOTSTRAP_IP=$(getOrgIp ${TEST_ORG1}) BOOTSTRAP_SERVICE_URL='http' \
        envsubst < test/resources/org_env/org2_env > "${TEST_ORG2}"_env
exit
        eval $(docker-machine env ${TEST_ORG1}.${DOMAIN})
        export DOCKER_COMPOSE_ARGS="${DOCKER_C_ARGS}"
        ./deploy.sh ${TEST_ORG1}

        eval $(docker-machine env ${TEST_ORG2}.${DOMAIN})
        export DOCKER_COMPOSE_ARGS="${DOCKER_C_ARGS}"
        ./deploy.sh ${TEST_ORG2}
        eval $(docker-machine env --unset)

        popd >/dev/null
    ;;
    *)
        echo "Wrong target [${DEPLOYMENT_TARGET}]"
    ;;
esac
