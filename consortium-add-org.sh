#!/usr/bin/env bash
source lib.sh
usageMsg="$0 newOrg [consortiumName=SampleConsortium]"
exampleMsg="$0 org1"

IFS=
NEWORG=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWORG_DOMAIN=${2:-$DOMAIN}
NEWORG_WWW_PORT=${3:-80}
consortiumName=${4:-"SampleConsortium"}

echo "Add $NEWORG at ${NEWORG_DOMAIN} to consortium $consortiumName"

EXECUTE_BY_ORDERER=1 ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} runCLI "container-scripts/orderer/consortium-add-org.sh ${NEWORG} ${NEWORG_WWW_PORT} ${NEWORG_DOMAIN} ${consortiumName}"