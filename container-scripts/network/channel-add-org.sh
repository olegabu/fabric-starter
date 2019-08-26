#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
newOrg=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
newOrgAnchorPeerPort=${3:-7051}
newOrgDomain=${4:-$DOMAIN}

downloadOrgMSP ${newOrg} $newOrgDomain
addOrgToChannel $channelName $newOrg $newOrgAnchorPeerPort

