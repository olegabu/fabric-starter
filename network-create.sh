#!/usr/bin/env bash

./network-create-base.sh orderer $@

./network-update-common-dns.sh orderer $@
