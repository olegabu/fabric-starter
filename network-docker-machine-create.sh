#!/usr/bin/env bash
source lib/util/util.sh

./host-create.sh ${@:-org1}

./network-create.sh ${@}
