#!/usr/bin/env bash
source lib.sh

newOrg=${1:?New org must be specified}
channelName=${2:?"Channel channel name must be specified"}

echo "Add new org '$newOrg' to channel $channelName"
addOrgToChannel $newOrg $channelName