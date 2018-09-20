#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName "
exampleMsg="$0 common "

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

joinChannel "$channelName"