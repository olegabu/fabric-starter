#!/usr/bin/env bash

source lib/util/util.sh
source lib.sh

export MULTIHOST=true
: ${CHANNEL:=common}

declare -A -g ORGS_MAP; parseOrganizationsForDockerMachine ${@:-org1}
orgs=(`getCurrentOrganizationsList`)
first_org=${orgs[0]:-org1}

# Set WORK_DIR as home dir on remote machine
setMachineWorkDir $first_org

# Add member organizations to the consortium
connectMachine orderer

for org in ${orgs}
do
    info "Adding $org to the consortium"
    ./consortium-add-org.sh ${org}
done

# First organization creates application channel
createChannelAndAddOthers ${CHANNEL}

# First organization creates common channel if it's not the default application channel
if [[ ${CHANNEL} != common ]]; then
    createChannelAndAddOthers common
fi

# First organization instantiates dns chaincode
connectMachine ${first_org}

sleep 10
info "Instantiating dns chaincode by $ORG"
./chaincode-instantiate.sh common dns

info "Waiting for dns chaincode to build"
sleep 20

# First organization creates entries in dns chaincode

ip=$(getMachineIp orderer)
./chaincode-invoke.sh common dns "[\"put\",\"$ip\",\"www.${DOMAIN} orderer.${DOMAIN}\"]"

for org in ${orgs}
do
    ip=$(getMachineIp ${org})
    ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${org}.${DOMAIN}\", \"$ip\"]"
done

sleep 10

./smoke-test.sh ${@}

echo
