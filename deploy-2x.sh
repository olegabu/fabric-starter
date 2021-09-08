#!/usr/bin/env bash

export FABRIC_VERSION=${FABRIC_VERSION:-2.3}
export FABRIC_STARTER_VERSION=${FABRIC_STARTER_VERSION:-2x}

export WGET_CMD="wget -P"
export BASE64_UNWRAP_CODE="| tr -d '\n'"

./deploy.sh $@