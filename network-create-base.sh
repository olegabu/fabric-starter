#!/usr/bin/env bash

source lib/util/util.sh
source lib.sh

setDocker_LocalRegistryEnv

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}
export WAIT_BEFORE_INSTALL_CHAINCODES=${WAIT_BEFORE_INSTALL_CHAINCODES:-60}

: ${DOCKER_COMPOSE_ARGS:= -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-multihost.yaml -f docker-compose-api-port.yaml }
: ${CHAINCODE_HOME:=chaincode}
: ${WEBAPP_HOME:=webapp}
: ${MIDDLEWARE_HOME:=middleware}

ordererMachineName=${1:-orderer}
shift

declare -a ORGS_MAP=${@:-org1}
orgs=`parseOrganizationsForDockerMachine ${ORGS_MAP}`
first_org=${orgs%% *}

echo "Orderer machine: $ordererMachineName, First org:$first_org, Orgs: $orgs"

# Set WORK_DIR as home dir on remote machine
setMachineWorkDir $ordererMachineName

BOOTSTRAP_IP=$(getMachineIp $ordererMachineName)
export BOOTSTRAP_IP

hosts="# created by network-create.sh\n${BOOTSTRAP_IP} www.${DOMAIN} orderer.${DOMAIN}"
# Collect IPs of remote hosts into a hosts file to copy to all hosts to be used as /etc/hosts to resolve all names
for org in ${orgs}; do
    ip=$(getMachineIp ${org})
    hosts="${hosts}\n${ip} www.${org}.${DOMAIN} peer0.${org}.${DOMAIN}"
done

info "Building network for $DOMAIN using WORK_DIR=$WORK_DIR on remote machines, CHAINCODE_HOME=$CHAINCODE_HOME, WEBAPP_HOME=$WEBAPP_HOME on local host. Hosts file:"
cat hosts

# Copy files to orderer

info "Copy files to orderer"

copyDirToMachine $ordererMachineName templates ${WORK_DIR}/templates
copyDirToMachine $ordererMachineName container-scripts ${WORK_DIR}/container-scripts

connectMachine $ordererMachineName

docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}; \
docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}; \

./clean.sh
# Copy generated hosts file to the host machines
echo -e "${hosts}" > hosts

createHostsFileInOrg $ordererMachineName orderer

# Create member organizations

function startOrg() {
    local org=${1?: org is required}
    local ordererMachineName=${2?: ordererMachineName is required}
    local idemix_keys=${WORK_DIR}/crypto-config/peerOrganizations/${ORG}.${DOMAIN}/idemix/msp

    info "Copying custom chaincodes and middleware to remote machine ${machine}"
    copyDirToMachine ${org} templates ${WORK_DIR}
    copyDirToMachine ${org} ${CHAINCODE_HOME} ${WORK_DIR}
    copyDirToMachine ${org} ${WEBAPP_HOME} ${WORK_DIR}
    copyDirToMachine ${org} ${MIDDLEWARE_HOME} ${WORK_DIR}
    #idemix
    if [ ${IDEMIX} == "TRUE" ]; then
        createDirInMachine ${org} ${idemix_keys}
    fi
#
#    info "Copying dns chaincode and middleware to remote machine ${machine}"
#    orgMachineName=`getDockerMachineName $org`
#    docker-machine scp -r chaincode ${orgMachineName}:${WORK_DIR}
#    docker-machine scp middleware/dns.js ${orgMachineName}:${WORK_DIR}/middleware/dns.js
#    copyDirToMachine ${org} container-scripts ${WORK_DIR}/container-scripts


    info "Creating member organization $org"
    export MY_IP=$(getMachineIp ${org})
    if [[ -z `getHostOrgForOrg $org` && ("${org}" != "$ordererMachineName") ]]; then
        bash -c "source lib.sh; \
         connectMachine ${org}; \
         docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}; \
         docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}; \
        ./clean.sh; \
        sleep 1; \
        "
    fi

    echo -e "${hosts}" > hosts
    createHostsFileInOrg $org

    bash -c "source lib.sh; connectMachine ${org}; MY_IP=$(getMachineIp ${org}) ORDERER_WWW_PORT=${ORDERER_WWW_PORT} docker-compose ${DOCKER_COMPOSE_ARGS} up -d; "

    if [ ${IDEMIX} == "TRUE" ]; then
        sleep 4
        local orgMachineName=$(getHostOrgForOrg $org).${DOMAIN}
        docker-machine ssh ${orgMachineName} sudo docker cp ca.${org}.${DOMAIN}:/etc/hyperledger/fabric-ca-server/IssuerPublicKey ${idemix_keys}
        docker-machine ssh ${orgMachineName} sudo docker cp ca.${org}.${DOMAIN}:/etc/hyperledger/fabric-ca-server/IssuerRevocationPublicKey ${idemix_keys}
        docker-machine ssh ${orgMachineName} sudo mv ${idemix_keys}/IssuerRevocationPublicKey ${idemix_keys}/RevocationPublicKey 
    fi
}


for org in ${orgs}
do

#    info "Copying custom chaincodes and middleware to remote machine ${machine}"
#    copyDirToMachine ${org} templates ${WORK_DIR}/templates
#    copyDirToMachine ${org} ${CHAINCODE_HOME} ${WORK_DIR}/chaincode
#    copyDirToMachine ${org} ${WEBAPP_HOME} ${WORK_DIR}/webapp
#    copyDirToMachine ${org} ${MIDDLEWARE_HOME} ${WORK_DIR}/middleware
#
#    info "Copying dns chaincode and middleware to remote machine ${machine}"
#    orgMachineName=`getDockerMachineName $org`
#    docker-machine scp -r chaincode ${orgMachineName}:${WORK_DIR}
#    docker-machine scp middleware/dns.js ${orgMachineName}:${WORK_DIR}/middleware/dns.js
#    copyDirToMachine ${org} container-scripts ${WORK_DIR}/container-scripts
#
#    info "Creating member organization $org"
#    connectMachine ${org}
#    export MY_IP=$(getMachineIp ${org})
#    [[ -z `getHostOrgForOrg $org` && ("${org}" != "$ordererMachineName") ]] && ./clean.sh && sleep 2
#    echo -e "${hosts}" > hosts
#    createHostsFileInOrg $org
#
#    connectMachine ${org}
#    ORDERER_WWW_PORT=${ORDERER_WWW_PORT} docker-compose ${DOCKER_COMPOSE_ARGS} up -d
    startOrg ${org} ${ordererMachineName}
    procId=$!
    sleep 1
done

wait ${procId}

echo -e "\n\nCreate BASE completed\n"

# Create orderer organization

info "Create orderer organization"

if [[ -n "`getHostOrgForOrg ${first_org}`" || ("${first_org}" == "$ordererMachineName") ]]; then
    ORDERER_WWW_PORT=$((${WWW_PORT:-80}+1))
    echo "Orderer WWW_PORT: $ORDERER_WWW_PORT"
fi

WWW_PORT=${ORDERER_WWW_PORT:-$WWW_PORT} docker-compose -f docker-compose-orderer.yaml -f docker-compose-open-net.yaml -f docker-compose-orderer-multihost.yaml up -d

