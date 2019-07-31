#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

NEWORG=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
consortiumName=${2:-"SampleConsortium"}

downloadOrgMSP ${NEWORG}
txTranslateChannelConfigBlock ${SYSTEM_CHANNEL_ID}
updateConsortium $NEWORG ${SYSTEM_CHANNEL_ID}