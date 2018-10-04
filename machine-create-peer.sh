#!/usr/bin/env bash
source lib.sh
usageMsg="$0 swarmToken swarmManagerIp [org=org1] [domain=example.com]"
exampleMsg="$0 SWMTKN-1-4fbasgnyfz5uqhybbesr9gbhg0lqlcj5luotclhij87owzd4ve-4k16civlmj3hfz1q715csr8lf 192.168.99.102 org3"

IFS=
swarmToken=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
swarmManagerIp=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
org=${3-org1}
domain=${4-example.com}

export ORG=${org}
export DOMAIN=${domain}

printInColor "1;32" "Creating machine $ORG in $DOMAIN"

export ORGS="{\"$ORG\":\"peer0.$ORG.$DOMAIN:7051\"}" CAS="{\"$ORG\":\"ca.$ORG.$DOMAIN:7054\"}"
docker-machine create --driver virtualbox ${ORG}
eval "$(docker-machine env ${ORG})"
docker swarm join --token ${swarmToken} ${swarmManagerIp}:2377
docker run -dit --name alpine --network fabric-overlay alpine
docker-machine scp -r templates ${ORG}:templates
docker-machine scp -r chaincode ${ORG}:chaincode

./clean.sh
./generate-peer.sh
docker-compose -f docker-compose.yaml -f multihost.yaml up

printInColor "1;32" "Created machine $ORG"



