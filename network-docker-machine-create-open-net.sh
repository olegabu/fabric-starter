#!/usr/bin/env bash
source lib/util/util.sh

./host-create.sh ${@}

./network-create-open-net.sh ${@}
