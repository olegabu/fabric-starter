#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion


NEWORDERER_NAME=${1}
NEWORDERER_DOMAIN=${2:-${DOMAIN:-example.com}}

EXECUTE_BY_ORDERER=1 runCLI "container-scripts/ops/raft-add-consenter.sh $NEWORDERER_NAME $NEWORDERER_DOMAIN"
