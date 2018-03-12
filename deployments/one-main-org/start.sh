#!/usr/bin/env bash

: ${FABRIC_STARTER_HOME:=../..}

! [[ -f env ]] && cp $FABRIC_STARTER_HOME/env_default env && echo "Adjust environment in the env file before create network" && exit 1

export FABRIC_STARTER_HOME=$FABRIC_STARTER_HOME
source ./env


$FABRIC_STARTER_HOME/network.sh -m removeArtifacts

echo "THIS_ORG: $THIS_ORG"
$FABRIC_STARTER_HOME/network.sh -m generate-peer -o $THIS_ORG -a 4000 -w 8081

exit
$FABRIC_STARTER_HOME/network.sh -m generate-orderer
