#!/usr/bin/env bash
source lib.sh

runCLI "rm -rf crypto-config/peerOrganizations/$ORG.$DOMAIN \
    && envsubst <templates/cryptogen-peer-template.yaml >crypto-config/cryptogen-$ORG.yaml \
    && cryptogen generate --config=crypto-config/cryptogen-$ORG.yaml \
    && mv crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/sk.pem \
    && chown $UID -R crypto-config/"