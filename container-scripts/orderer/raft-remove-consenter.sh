#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

CONSENTER_INDEX=${1:?Consenter index to remove is requried}

echo -e "\n\nRemove new consenter: Index: $CONSENTER_INDEX\n\n"

$BASEDIR/../ops/remove-from-config.sh channel_group.values.OrdererAddresses.value.addresses[${CONSENTER_INDEX}]
sleep 5
$BASEDIR/../ops/remove-from-config.sh channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters[${CONSENTER_INDEX}]

