#!/usr/bin/env bash

export WGET_CMD="wget -P"
export BASE64_UNWRAP_CODE="| tr -d '\n'"

./deploy.sh $@