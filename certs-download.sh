#!/usr/bin/env bash
source lib.sh
usageMsg="$0 orgName"
exampleMsg="$0 org1"

IFS=
remoteOrg=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

downloadMSP ${remoteOrg}
