#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh 2>/dev/null
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

channel=${1}
org=${2}

listChaincodesInstalled $channel $org
