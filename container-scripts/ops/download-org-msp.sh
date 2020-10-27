#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

newOrg=${1:?org is required}
newOrgDomain=${2:-$DOMAIN}

downloadOrgMSP ${newOrg} $newOrgDomain

