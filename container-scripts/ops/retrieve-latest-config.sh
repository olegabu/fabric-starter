#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

NEWCONSENTER_NAME=${1:?New Orderer name is requried}
NEWCONSENTER_ORG=${2:?New orderer org hosting certificates is requreid}
NEWCONSENTER_DOMAIN=${3}

txTranslateChannelConfigBlock ${SYSTEM_CHANNEL_ID}

sleep 1

updatedConfigBlockDir=crypto-config/ordererOrganizations/${DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/genesis
updatedConfigBlockDirOnPeer=crypto-config/peerOrganizations/${ORG}.${DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/genesis

echo "Copy updated genesis block to ${updatedConfigBlockDir}"
set -x
mkdir -p ${updatedConfigBlockDir}
mkdir -p ${updatedConfigBlockDirOnPeer}
cp crypto-config/configtx/${SYSTEM_CHANNEL_ID}.pb ${updatedConfigBlockDir}/${SYSTEM_CHANNEL_ID}_remote.pb
cp crypto-config/configtx/${SYSTEM_CHANNEL_ID}.pb ${updatedConfigBlockDirOnPeer}/${SYSTEM_CHANNEL_ID}_remote.pb
set +x


sleep 5