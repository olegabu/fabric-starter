#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

NEWORG=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWORG_DOMAIN=${2:-$DOMAIN}
consortiumName=${3:-"SampleConsortium"}

downloadOrgMSP ${NEWORG} ${NEWORG_DOMAIN}
txTranslateChannelConfigBlock ${SYSTEM_CHANNEL_ID}
updateConsortium $NEWORG ${SYSTEM_CHANNEL_ID} ${NEWORG_DOMAIN}