#!/usr/bin/env bash

source lib.sh
source lib/util/util.sh

export MULTIHOST=true
export DOMAIN=${DOMAIN:-example.com}

declare -a ORGS_MAP=${@:-org1}
orgs=`parseOrganizationsForDockerMachine ${ORGS_MAP}`
first_org=${orgs%% *}

ip=$(getMachineIp ${first_org})

info "Smoke test logs into $first_org at $ip and queries dns chaincode via rest api"
sleep 5
jwt=`(curl -d "{\"username\":\"${DNS_USERNAME:-user1}\",\"password\":\"${DNS_PASSWORD:-pass}\"}" -H "Content-Type: application/json" http://${ip}:4000/users | tr -d '"')`
sleep 1
curl -H "Authorization: Bearer $jwt" "http://$ip:4000/channels/common/chaincodes/dns?fcn=range"
echo
