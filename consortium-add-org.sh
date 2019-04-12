#!/usr/bin/env bash
source lib.sh
usageMsg="$0 newOrg [systemChannelName=orderer-system-channel] [consortiumName=SampleConsortium]"
exampleMsg="$0 org1"

IFS=
NEWORG=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
systemChannelName=${2:-"orderer-system-channel"}
consortiumName=${3:-"SampleConsortium"}

echo "Add $NEWORG to consortium $consortiumName"
#EXECUTE_BY_ORDERER=1 downloadMSP ${NEWORG}
#EXECUTE_BY_ORDERER=1 txTranslateChannelConfigBlock "orderer-system-channel"
EXECUTE_BY_ORDERER=1 updateConsortium $NEWORG $systemChannelName $consortiumName
