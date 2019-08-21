#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

env|sort
installChaincodePackage "$chaincodeName"