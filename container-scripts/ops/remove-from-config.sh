#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

jsonPath=${1:?Json path to remove is required}
channel=${2:-${SYSTEM_CHANNEL_ID}}

txTranslateChannelConfigBlock ${channel}

removeObjectFromChannelConfig ${channel} 'crypto-config/configtx/config.json' "$jsonPath"

createConfigUpdateEnvelope ${channel}

