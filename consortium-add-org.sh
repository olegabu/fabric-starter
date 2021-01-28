#!/usr/bin/env bash
source lib.sh
usageMsg="$0 newOrg [consortiumName=SampleConsortium]"
exampleMsg="$0 org1"

IFS=
NEWORG=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWORG_DOMAIN=${2:-$DOMAIN}
consortiumName=${3:-"SampleConsortium"}

echo "Add $NEWORG to consortium $consortiumName"

EXECUTE_BY_ORDERER=1 ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} runCLI "container-scripts/orderer/consortium-add-org.sh ${NEWORG} ${NEWORG_DOMAIN}"