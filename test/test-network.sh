#!/usr/bin/env bash

export TEST_CHANNEL_NAME=
source ./local-test-env.sh test.net sberbank vtb

./cli/create-channel.sh
./verify/test-exist-channel.sh
export TEST_CHANNEL_NAME=
source ./local-test-env.sh test.net sberbank vtb     
./curl/create-channel.sh                             
./verify/test-exist-channel.sh   