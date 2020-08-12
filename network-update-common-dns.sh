#!/usr/bin/env bash

source lib/util/util.sh
source lib.sh

setDocker_LocalRegistryEnv

export MULTIHOST=true
: ${CHANNEL:=common}

ordererMachineName=${@:-orderer}
shift

declare -a ORGS_MAP=${@:-org1}
orgs=`parseOrganizationsForDockerMachine ${ORGS_MAP}`
first_org=${orgs%% *}

# Set WORK_DIR as home dir on remote machine
setMachineWorkDir $first_org

for org in ${orgs}
do
    connectMachine ${org}
    ./chaincode-install.sh dns 1.0 /opt/chaincode/node/dns node

done

# Add member organizations to the consortium
connectMachine $ordererMachineName

for org in ${orgs}
do
    info "Adding $org to the consortium"
    ./consortium-add-org.sh ${org}
done

# First organization creates application channel
createChannelAndAddOthers ${CHANNEL} $first_org $orgs

# First organization creates common channel if it's not the default application channel
if [[ ${CHANNEL} != common ]]; then
    createChannelAndAddOthers common $first_org $orgs
fi

# First organization instantiates dns chaincode
connectMachine ${first_org}

info "Instantiating dns chaincode by $ORG"
sleep 10
./chaincode-instantiate.sh common dns

info "Waiting for dns chaincode to build"
sleep 5

# First organization creates entries in dns chaincode

ip=$(getMachineIp $ordererMachineName)
#./chaincode-invoke.sh common dns "[\"put\",\"$ip\",\"www.${DOMAIN} $ordererMachineName.${DOMAIN}\"]"

for org in ${orgs}
do
    ip=$(getMachineIp ${org})
    connectMachine ${org}
    ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${org}.${DOMAIN}\", \"$ip\"]" # TODO: update registerOrg
#    value="\"peer0.${org}.${DOMAIN} www.${org}.${DOMAIN}"
#    hostOrg=`getHostOrgForOrg $org`
#    [ -n "$hostOrg" ] && value="$value www.${DOMAIN} $ordererMachineName.${DOMAIN}"
#    value="$value\""

#    ./chaincode-invoke.sh common dns "[\"put\",\"$ip\",$value]"
#    sleep 10
done

sleep 20

./smoke-test.sh ${@}

echo
