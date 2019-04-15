#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh

setDocker_LocalRegistryEnv

if [ -n "$DOCKER_REGISTRY" ]; then
    DOCKER_MACHINE_FLAGS="${DOCKER_MACHINE_FLAGS} --engine-insecure-registry $DOCKER_REGISTRY  --virtualbox-cpu-count 2"
    echo "Using docker-registry: $DOCKER_REGISTRY"
fi

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

info "Create Network with vm names prefix: $VM_NAME_PREFIX"
#read -n1 -r -p "Press any key to continue..." key

: ${DOMAIN:=example.com}

declare -A -g ORGS_MAP; parseOrganizationsForDockerMachine ${@:-org1}
orgs=`getCurrentOrganizationsList`
first_org=${orgs%% *}

echo "Organizations: ${orgs[@]}. First: $first_org"

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
    [ -z "${ORGS_MAP[$org]}" ] && docker-machine rm ${orgMachineName} --force
    docker-machine create ${DOCKER_MACHINE_FLAGS} ${orgMachineName}
done

