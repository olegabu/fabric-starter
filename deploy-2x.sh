#!/usr/bin/env bash

export FABRIC_VERSION=${FABRIC_VERSION:-2.3}
export FABRIC_STARTER_VERSION=${FABRIC_STARTER_VERSION:-snapshot-0.13-2.3}

./deploy.sh $@
