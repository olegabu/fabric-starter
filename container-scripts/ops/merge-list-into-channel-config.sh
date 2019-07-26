#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

channel=${1:?Channel is requried}
configInputFile=${2:?Config input file is requried}
configJsonPath=${3:?Json path to update is required}
mergedFile=${4:?File with values to merge is required}
mergedFileJsonPath=${5:?Path in the file with values is required}
outputFile=${6:-crypto-config/configtx/updated_config.json}

txTranslateChannelConfigBlock ${SYSTEM_CHANNEL_ID}

mergeListIntoChannelConfig ${channel} "${configInputFile}" "${configJsonPath}" "${mergedFile}" "${mergedFileJsonPath}" "${outputFile}"

createConfigUpdateEnvelope ${channel}

