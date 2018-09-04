#!/usr/bin/env bash

source lib.sh

run "rm -rf crypto-config/peerOrganizations/$ORG.$DOMAIN \
&& sed -e 's/DOMAIN/$DOMAIN/g' -e 's/ORG/$ORG/g' templates/cryptogen-peer-template.yaml > crypto-config/cryptogen-$ORG.yaml \
&& cryptogen generate --config=crypto-config/cryptogen-$ORG.yaml \
&& mv crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/sk.pem"
