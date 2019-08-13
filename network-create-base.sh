#!/usr/bin/env bash

source lib/util/util.sh
source lib.sh

setDocker_LocalRegistryEnv

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}

: ${DOCKER_COMPOSE_ARGS:= -f docker-compose.yaml -f docker-compose-couchdb.yaml -f multihost.yaml }
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

# Create orderer organization

info "Creating orderer organization"

copyDirToMachine $ordererMachineName templates ${WORK_DIR}/templates
copyDirToMachine $ordererMachineName container-scripts ${WORK_DIR}/container-scripts

connectMachine $ordererMachineName
./clean.sh
# Copy generated hosts file to the host machines
echo -e "${hosts}" > hosts

createHostsFileInOrg $ordererMachineName orderer

if [[ -n "`getHostOrgForOrg ${first_org}`" || ("${first_org}" == "$ordererMachineName") ]]; then
    ORDERER_WWW_PORT=$((${WWW_PORT:-80}+1))
    echo "Orderer WWW_PORT: $ORDERER_WWW_PORT"
fi

WWW_PORT=${ORDERER_WWW_PORT:-$WWW_PORT} docker-compose -f docker-compose-orderer.yaml -f docker-compose-open-net.yaml -f docker-compose-orderer-multihost.yaml up -d

# Create member organizations

for org in ${orgs}
do

    info "Copying custom chaincodes and middleware to remote machine ${machine}"
    copyDirToMachine ${org} templates ${WORK_DIR}/templates
    copyDirToMachine ${org} ${CHAINCODE_HOME} ${WORK_DIR}/chaincode
    copyDirToMachine ${org} ${WEBAPP_HOME} ${WORK_DIR}/webapp
    copyDirToMachine ${org} ${MIDDLEWARE_HOME} ${WORK_DIR}/middleware

    info "Copying dns chaincode and middleware to remote machine ${machine}"
    orgMachineName=`getDockerMachineName $org`
    docker-machine scp -r chaincode ${orgMachineName}:${WORK_DIR}
    docker-machine scp middleware/dns.js ${orgMachineName}:${WORK_DIR}/middleware/dns.js
    copyDirToMachine ${org} container-scripts ${WORK_DIR}/container-scripts

    info "Creating member organization $org"
    connectMachine ${org}
    export MY_IP=$(getMachineIp ${org})
    [[ -z `getHostOrgForOrg $org` && ("${org}" != "$ordererMachineName") ]] && ./clean.sh && sleep 2
    echo -e "${hosts}" > hosts
    createHostsFileInOrg $org

    docker-compose ${DOCKER_COMPOSE_ARGS} up -d
done

