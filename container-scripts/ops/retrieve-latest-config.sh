#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

NEWCONSENTER_NAME=${1:?New Orderer name is requried}
NEWCONSENTER_DOMAIN=${2:?-Consenter domain is required}
ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN}

txTranslateChannelConfigBlock ${SYSTEM_CHANNEL_ID}

sleep 1

updatedConfigBlockDir=crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/genesis
#updatedConfigBlockDirOnPeer=crypto-config/peerOrganizations/${ORG}.${DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/genesis

echo "Copy updated genesis block to ${updatedConfigBlockDir}"
set -x
mkdir -p ${updatedConfigBlockDir}
#mkdir -p ${updatedConfigBlockDirOnPeer}
cp crypto-config/configtx/${SYSTEM_CHANNEL_ID}.pb ${updatedConfigBlockDir}/${SYSTEM_CHANNEL_ID}_remote.pb
#cp crypto-config/configtx/${SYSTEM_CHANNEL_ID}.pb ${updatedConfigBlockDirOnPeer}/${SYSTEM_CHANNEL_ID}_remote.pb
set +x

