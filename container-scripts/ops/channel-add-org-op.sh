#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

channelName=${1:?channel name is required}
newOrg=${2:?org is required}
newOrgAnchorPeerPort=${3:-7051}
newOrgDomain=${4:-$DOMAIN}

addOrgToChannel $channelName $newOrg $newOrgAnchorPeerPort $newOrgDomain

