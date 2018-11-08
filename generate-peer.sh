#!/usr/bin/env bash
source lib.sh

## Workaround until docker-compose issue 4601 is solved
# https://github.com/docker/compose/issues/4601
[ -n "${DOCKER_HOST}" ] && docker run -dit --name alpine --network fabric-overlay alpine

IFS='.' read -r -a subDomains <<< ${DOMAIN}

echo $DOMAIN
if [ -z "$LDAP_BASE_DN" ]; then
    for subDomain in ${subDomains[@]}; do
        [ -n "${LDAP_BASE_DN}" ] && COMMA=,
        LDAP_BASE_DN="${LDAP_BASE_DN}${COMMA}dc=$subDomain"
    done
    export LDAP_BASE_DN
fi

[ -n "$LDAP_ENABLED" ] && echo "LDAP Url used: $LDAP_BASE_DN"

envSubst "templates/cryptogen-peer-template.yaml" "crypto-config/cryptogen-$ORG.yaml"
envSubst "templates/fabric-ca-server-template.yaml" "crypto-config/fabric-ca-server-config-$ORG.yaml" "export LDAP_BASE_DN=${LDAP_BASE_DN}"
runCLI "rm -rf crypto-config/peerOrganizations/$ORG.$DOMAIN \
    && cryptogen generate --config=crypto-config/cryptogen-$ORG.yaml \
    && mv crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/sk.pem \
    && mv crypto-config/peerOrganizations/$ORG.$DOMAIN/users/Admin@$ORG.$DOMAIN/msp/keystore/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/users/Admin@$ORG.$DOMAIN/msp/keystore/sk.pem \
    && cp -r crypto-config/ordererOrganizations/$DOMAIN/msp/* crypto-config/peerOrganizations/$ORG.$DOMAIN/msp \
    || chown $UID -R crypto-config/"