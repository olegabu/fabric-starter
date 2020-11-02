#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

newOrg=${1:?org is required}
newOrgWwwPort=${2:-80}
newOrgDomain=${3:-$DOMAIN}

downloadOrgMSP ${newOrg} ${newOrgWwwPort} $newOrgDomain

