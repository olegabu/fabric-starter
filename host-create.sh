#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh

setDocker_LocalRegistryEnv

if [ -n "$DOCKER_REGISTRY" ]; then
    DOCKER_MACHINE_FLAGS="${DOCKER_MACHINE_FLAGS} --engine-insecure-registry $DOCKER_REGISTRY  "
fi

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

info "Create Network with vm names prefix: $VM_NAME_PREFIX"
#read -n1 -r -p "Press any key to continue..." key

: ${DOMAIN:=example.com}

declare -a ORGS_MAP=${@:-org1}
orgs=`parseOrganizationsForDockerMachine ${ORGS_MAP}`
first_org=${orgs%% *}


# Create orderer host machine
ordererMachineName="orderer.$DOMAIN"

info "Creating $ordererMachineName, Options: $DOCKER_MACHINE_FLAGS"

docker-machine rm ${ordererMachineName} --force
docker-machine create ${DOCKER_MACHINE_FLAGS} ${ordererMachineName}

# Create member organizations host machines

for org in ${orgs}
do
    orgMachineName=`getDockerMachineName $org`
    info "Creating member organization $org on machine: $orgMachineName with flags: $DOCKER_MACHINE_FLAGS"
    [ -z `getHostOrgForOrg $org` ] && docker-machine rm ${orgMachineName} --force
    docker-machine create ${DOCKER_MACHINE_FLAGS} ${orgMachineName}
done

