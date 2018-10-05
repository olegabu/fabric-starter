#!/usr/bin/env bash
source lib.sh
usageMsg="$0 org=org1 [swarmToken] [swarmManagerIp] [domain=example.com]"
exampleMsg="$0 org3 SWMTKN-1-4fbasgnyfz5uqhybbesr9gbhg0lqlcj5luotclhij87owzd4ve-4k16civlmj3hfz1q715csr8lf 192.168.99.100"

IFS=
org=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
swarmToken=${2}
swarmManagerIp=${3}
domain=${4-example.com}

export ORG=${org}
export DOMAIN=${domain}

printInColor "1;33" "Creating machine $ORG in $DOMAIN"

if [ -z "$swarmToken" ]; then
    printInColor "1;35" "get swarm token and swarm manager ip address from 'orderer' machine"
    eval $(docker-machine env orderer)
    swarmToken=`docker swarm join-token worker -q`
    swarmManagerIp=`docker-machine ip orderer`
    [ $? -ne 0 ] && printRedYellow "'orderer' machine is not available. Create 'orderer' machine first or specify swarmToken and swarmManagerIp to join to." && exit 1
fi


export ORGS="{\"$ORG\":\"peer0.$ORG.$DOMAIN:7051\"}" CAS="{\"$ORG\":\"ca.$ORG.$DOMAIN:7054\"}"
docker-machine create --driver virtualbox ${ORG}
eval "$(docker-machine env ${ORG})"
echo; env | grep DOCKER; echo
docker swarm join --token ${swarmToken} ${swarmManagerIp}:2377
docker run -dit --name alpine --network fabric-overlay alpine
docker-machine scp -r templates ${ORG}:templates
docker-machine scp -r chaincode ${ORG}:chaincode

./clean.sh
./generate-peer.sh
docker-compose -f docker-compose.yaml -f multihost.yaml up

printInColor "1;32" "Created machine $ORG"



