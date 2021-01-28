#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh

usageMsg="$0 orgName bootstrapIp myIp [reuseOldConfig=false]"
exampleMsg="$0 org2 192.168.99.100 192.168.99.102 true"
#
IFS=
org=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
boostrapIp=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
myIp=${3:?`printUsage "$usageMsg" "$exampleMsg"`}
unset IFS
cleanBeforeStart=${4}

setDocker_LocalRegistryEnv # local DOCKER_REGISTRY if started


: ${DOCKER_COMPOSE_ARGS:= -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-multihost.yaml -f docker-compose-api-port.yaml}

connectMachine ${org}
[ "${reuseOldConfig}" ] || ./clean.sh

info "\n\nStart node for org: ${org} on IP: ${IP} with bootsrap on ${boostrapIp}\n\n"
ORG=${org} MY_IP=${myIp} BOOTSTRAP_IP=${boostrapIp} MULTIHOST=true docker-compose ${DOCKER_COMPOSE_ARGS} up -d

