#!/usr/bin/env bash
source lib.sh

envSubst "templates/cryptogen-peer-template.yaml" "crypto-config/cryptogen-$ORG.yaml"
runCLI "rm -rf crypto-config/peerOrganizations/$ORG.$DOMAIN \
    && cryptogen generate --config=crypto-config/cryptogen-$ORG.yaml \
    && mv crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/sk.pem \
    && mv crypto-config/peerOrganizations/$ORG.$DOMAIN/users/Admin@$ORG.$DOMAIN/msp/keystore/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/users/Admin@$ORG.$DOMAIN/msp/keystore/sk.pem \
    && chown $UID -R crypto-config/"