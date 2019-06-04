#!/usr/bin/env bash
source lib/util/util.sh

./host-create.sh orderer ${@:-org1}

./network-create.sh ${@}
