#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

channelName=${1:?channel name is required}
newOrg=${2:?new org is required}
newOrgAnchorPeerPort=${3:-7051}
newOrgWwwPort=${4:-80}
newOrgDomain=${5:-$DOMAIN}

downloadOrgMSP ${newOrg} ${newOrgWwwPort} $newOrgDomain
addOrgToChannel $channelName $newOrg $newOrgAnchorPeerPort $newOrgDomain

