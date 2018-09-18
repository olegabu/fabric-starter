#!/usr/bin/env bash
source lib.sh

channelOwnerOrg=${1:?Parameters: <channel owner org> <channel name>}
channelName=${2:?Parameters: <channel owner org> <channel name>}

echo "Join org '$ORG' to channel $channelName"
joinChannel "$channelOwnerOrg" "$channelName"