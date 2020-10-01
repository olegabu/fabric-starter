#!/usr/bin/env bash

source lib/util/util.sh
source lib.sh

setDocker_LocalRegistryEnv

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}
export FABRIC_STARTER_REPOSITORY=olegabu
export WAIT_BEFORE_INSTALL_CHAINCODES=${WAIT_BEFORE_INSTALL_CHAINCODES:-60}

: ${DOCKER_COMPOSE_ARGS:= -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-multihost.yaml -f docker-compose-api-port.yaml }
: ${BOOTSTRAP_SERVICE_URL:=http}
: ${CHAINCODE_HOME:=chaincode}
: ${WEBAPP_HOME:=webapp}
: ${MIDDLEWARE_HOME:=middleware}

export  BOOTSTRAP_SERVICE_URL

ordererMachineName=${1:-orderer}
shift

declare -a ORGS_MAP=${@:-org1}
orgs=`parseOrganizationsForDockerMachine ${ORGS_MAP}`
first_org=${orgs%% *}

echo "Orderer machine: $ordererMachineName, First org:$first_org, Orgs: $orgs"

# Set WORK_DIR as home dir on remote machine
setMachineWorkDir $ordererMachineName

# Create orderer organization
info "Creating orderer organization"

copyDirToMachine $ordererMachineName templates ${WORK_DIR}/templates
copyDirToMachine $ordererMachineName container-scripts ${WORK_DIR}/container-scripts

connectMachine $ordererMachineName

docker pull ${DOCKER_REGISTRY:-docker.io}/${FABRIC_STARTER_REPOSITORY}/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}; \
docker pull ${DOCKER_REGISTRY:-docker.io}/${FABRIC_STARTER_REPOSITORY}/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}; \

./clean.sh

if [[ -n "`getHostOrgForOrg ${first_org}`" || ("${first_org}" == "$ordererMachineName") ]]; then
    ORDERER_WWW_PORT=$((${WWW_PORT:-80}+1))
    echo "Orderer WWW_PORT: $ORDERER_WWW_PORT"
fi

WWW_PORT=${ORDERER_WWW_PORT:-$WWW_PORT} docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up -d
    while true; do
        if [[ "" != `docker ps -aq -f "name= pre-install.${ORDERER_NAME:-orderer}.${ORDERER_DOMAIN:-${DOMAIN}}"` ]]; then
            break
        fi;
        sleep 1
    done
docker wait pre-install.${ORDERER_NAME:-orderer}.${ORDERER_DOMAIN:-${DOMAIN}}


# Create member organizations
function startOrg() {
    local org=${1:? org is required}
    local ordererMachineName=${2:? ordererMachineName is required}
    local first_org=${3:? first_org is required}

    info "Copying custom chaincodes and middleware to remote machine ${org}.${DOMAIN}"
    copyDirToMachine ${org} templates ${WORK_DIR}
    copyDirToMachine ${org} ${CHAINCODE_HOME} ${WORK_DIR}
    copyDirToMachine ${org} ${WEBAPP_HOME} ${WORK_DIR}
    copyDirToMachine ${org} ${MIDDLEWARE_HOME} ${WORK_DIR}
#
    info "Creating member organization $org"
    export MY_IP=$(getMachineIp ${org})
    if [[ -z `getHostOrgForOrg $org` && ("${org}" != "$ordererMachineName") ]]; then
        bash -c "source lib.sh; \
         connectMachine ${org}; \
         docker pull ${DOCKER_REGISTRY:-docker.io}/${FABRIC_STARTER_REPOSITORY}/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}; \
         docker pull ${DOCKER_REGISTRY:-docker.io}/${FABRIC_STARTER_REPOSITORY}/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}; \
        ./clean.sh; \
        sleep 1; \
        "
    fi

    bash -c "source lib.sh; connectMachine ${org}; ORG=${org} MY_IP=$(getMachineIp ${org}) ORDERER_WWW_PORT=${ORDERER_WWW_PORT} docker-compose ${DOCKER_COMPOSE_ARGS} up -d; \
    docker logs post-install.${org}.${DOMAIN}; \
    set -x; docker attach --no-stdin post-install.${org}.${DOMAIN}; set +x; "
}


for org in ${orgs}
do
    startOrg ${org} ${ordererMachineName} $first_org &
    procId=$!
    sleep 5
    BOOTSTRAP_IP=$(getMachineIp $ordererMachineName)
    export BOOTSTRAP_IP
    connectMachine $first_org
    set -x
    while true; do
        if [[ "" != `docker ps -aq -f "name=post-install.${first_org}.${DOMAIN}"` ]]; then
            break
        fi;
        sleep 1
    done
    docker wait post-install.${first_org}.${DOMAIN}
    set +x
done

wait ${procId}

echo -e "\n\nCreate BASE completed\n"

