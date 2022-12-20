#!/usr/bin/env bash

export FABRIC_VERSION=${FABRIC_VERSION:-2.3}
export FABRIC_STARTER_VERSION=${FABRIC_STARTER_VERSION:-hlf-2.3-stable}

./deploy.sh $@
