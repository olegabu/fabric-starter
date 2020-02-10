#!/usr/bin/env bash

source ./libs.sh
BASEDIR=$(dirname $0)

TEST_INTERFACE=${1:-${TEST_INTERFACE}} #cli or api



export TEST_CHANNEL_NAME=
source ./local-test-env.sh test.net sberbank vtb

./cli/create-channel.sh
./verify/test-exist-channel.sh
export TEST_CHANNEL_NAME=
#export DOMAIN=test.net
source ./local-test-env.sh test.net sberbank vtb
./curl/create-channel.sh
./verify/test-exist-channel.sh
#./curl/add-org-to-channel.sh
