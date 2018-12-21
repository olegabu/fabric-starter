#!/usr/bin/env bash
source lib.sh
usageMsg="$0  chaincodeName [version=1.0] [path to chaincode=/opt/chaincode/java/<chaincodeName>] [lang=java]"
exampleMsg="$0 reference 1.0 /opt/chaincode/java/reference java"
usageMsg="$0  chaincode-package-name"
exampleMsg="$0 reference.cds"

IFS=
chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}


installChaincodePackage "$chaincodeName"