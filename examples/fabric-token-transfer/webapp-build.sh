#!/usr/bin/env bash

pushd token-transfer-webapp
    npm install && au build --env prod
popd
