#!/usr/bin/env bash
BASEDIR=$(dirname "$0")

touch "crypto-config/fabric-ca-server-config-$ORG.yaml" # macOS workaround
touch "crypto-config/fabric-ca-server-config-$ORG.yaml"

if [ ! -f "crypto-config/hosts" ]; then #TODO
    export HOSTS_FILE_GENERATION_REQUIRED=true
    touch "crypto-config/hosts"
fi

source lib/container-lib.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/lib/container-lib.sh

: ${ORDERER_DOMAIN:=${ORDERER_DOMAIN:-${DOMAIN}}}
: ${ORDERER_NAME:=${ORDERER_NAME:-orderer}}

export ORDERER_DOMAIN ORDERER_NAME


function main() {
    tree crypto-config
    env|sort
    prepareLDAPBaseDN
    envsubst < "templates/fabric-ca-server-template.yaml" >> "crypto-config/fabric-ca-server-config-$ORG.yaml" #TODO:remove
    generateCryptoMaterialIfNotExists
    renameSecretKey #TODO: ?
    copyMspToNginxSharedFolder
    copyOrdererCertificatesForServingByPeerWWW
    copyWellKnownTLSCerts
    generateHostsFileIfNotExists
    tree /etc/hyperledger/crypto-config/peerOrganizations/
}

function prepareLDAPBaseDN() {
    IFS='.' read -r -a subDomains <<< ${DOMAIN}

    echo $DOMAIN
    if [ -z "$LDAP_BASE_DN" ]; then
        for subDomain in ${subDomains[@]}; do
            [ -n "${LDAP_BASE_DN}" ] && COMMA=,
            LDAP_BASE_DN="${LDAP_BASE_DN}${COMMA}dc=$subDomain"
        done
        export LDAP_BASE_DN
    fi

    [ -n "$LDAP_ENABLED" ] && echo "Using LDAP Url: $LDAP_BASE_DN"
}

function generateCryptoMaterialIfNotExists() {
    if [ ! -d "crypto-config/peerOrganizations/$ORG.$DOMAIN/peers/peer0.$ORG.$DOMAIN/msp" ]; then
        echo "Generation $ORG peer MSP."

        envsubst < "templates/cryptogen-peer-template.yaml" > "crypto-config/cryptogen-$ORG.yaml"
        cryptogen generate --config=crypto-config/cryptogen-$ORG.yaml
    else
        echo "$ORG MSP exists (crypto-config/peerOrganizations/$ORG.$DOMAIN/peers/peer0.$ORG.$DOMAIN/msp). Generation skipped."
    fi
}

function renameSecretKey() {
    [ ! -f "crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/sk.pem" ] && mv crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/ca/sk.pem
    [ ! -f "crypto-config/peerOrganizations/$ORG.$DOMAIN/tlsca/sk.pem" ] && mv crypto-config/peerOrganizations/$ORG.$DOMAIN/tlsca/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/tlsca/sk.pem
    [ ! -f "crypto-config/peerOrganizations/$ORG.$DOMAIN/users/Admin@$ORG.$DOMAIN/msp/keystore/sk.pem" ] && mv crypto-config/peerOrganizations/$ORG.$DOMAIN/users/Admin@$ORG.$DOMAIN/msp/keystore/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/users/Admin@$ORG.$DOMAIN/msp/keystore/sk.pem
    [ ! -f "crypto-config/peerOrganizations/$ORG.$DOMAIN/users/User1@$ORG.$DOMAIN/msp/keystore/sk.pem" ] && mv crypto-config/peerOrganizations/$ORG.$DOMAIN/users/User1@$ORG.$DOMAIN/msp/keystore/*_sk crypto-config/peerOrganizations/$ORG.$DOMAIN/users/User1@$ORG.$DOMAIN/msp/keystore/sk.pem
}

function copyMspToNginxSharedFolder() {
    mkdir -p crypto-config/node-certs/$ORG.$DOMAIN/msp
    cp -r crypto-config/peerOrganizations/$ORG.$DOMAIN/msp/* crypto-config/node-certs/$ORG.$DOMAIN/msp 2>/dev/null
}

function copyOrdererCertificatesForServingByPeerWWW() {
    cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/admincerts crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp 2>/dev/null
    cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/cacerts crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp 2>/dev/null
    cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/tlscacerts crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp 2>/dev/null

    #deprecated
    cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/* crypto-config/node-certs/$ORG.$DOMAIN/msp 2>/dev/null
    cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/* crypto-config/peerOrganizations/$ORG.$DOMAIN/msp 2>/dev/null
    ###########
}

function copyWellKnownTLSCerts() {
    mkdir -p crypto-config/node-certs/$ORG.$DOMAIN/msp/well-known
    cp crypto-config/peerOrganizations/$ORG.$DOMAIN/msp/tlscacerts/tlsca.$ORG.$DOMAIN-cert.pem crypto-config/node-certs/$ORG.$DOMAIN/msp/well-known/msp-admin.pem 2>/dev/null
    cp crypto-config/peerOrganizations/$ORG.$DOMAIN/msp/tlscacerts/tlsca.$ORG.$DOMAIN-cert.pem crypto-config/node-certs/$ORG.$DOMAIN/msp/well-known/tlsca-cert.pem 2>/dev/null

    #deprecated
    mkdir -p crypto-config/peerOrganizations/$ORG.$DOMAIN/msp/well-known
    cp crypto-config/peerOrganizations/$ORG.$DOMAIN/msp/tlscacerts/tlsca.$ORG.$DOMAIN-cert.pem crypto-config/peerOrganizations/$ORG.$DOMAIN/msp/well-known/msp-admin.pem 2>/dev/null
    cp crypto-config/peerOrganizations/$ORG.$DOMAIN/msp/tlscacerts/tlsca.$ORG.$DOMAIN-cert.pem crypto-config/peerOrganizations/$ORG.$DOMAIN/msp/well-known/tlsca-cert.pem 2>/dev/null
    ##########
}

function generateHostsFileIfNotExists() {
    if [ $HOSTS_FILE_GENERATION_REQUIRED ]; then
        if [[ -n "$BOOTSTRAP_IP" && "$BOOTSTRAP_IP" != "$MY_IP" ]]; then
            echo "Generating crypto-config/hosts"
            echo -en "#generated at bootstrap as part of crypto- and meta-information generation\n${BOOTSTRAP_IP}\t${ORDERER_NAME}.${ORDERER_DOMAIN} www.${ORDERER_DOMAIN} " > crypto-config/hosts
            if [ -n "$BOOTSTRAP_ORG" ]; then
                set -x
                echo " peer0.${BOOTSTRAP_ORG}.${BOOTSTRAP_DOMAIN:-$DOMAIN} www.${BOOTSTRAP_ORG}.${BOOTSTRAP_DOMAIN:-$DOMAIN} " >> crypto-config/hosts
                set +x
            else
                echo " " >> crypto-config/hosts
            fi
#             echo -e "\n\nDownload orderer MSP certs from $BOOTSTRAP_IP\n\n"
        else
            echo -e "#generated empty at bootstrap as part of crypto- and meta-information generation" > crypto-config/hosts
        fi
    else
        echo "crypto-config/hosts file exists. Generation skipped."
    fi

    if [[ -n "$BOOTSTRAP_IP" && "$BOOTSTRAP_IP" != "$MY_IP" && ! -f crypto-config/hosts ]]; then
        echo -e "#generated at bootstrap as part of crypto- and meta-information generation\n${BOOTSTRAP_IP}\t${ORDERER_NAME}.${ORDERER_DOMAIN} www.${ORDERER_DOMAIN} " > crypto-config/hosts
    fi

    echo -e "\ncrypto-config/hosts:\n"
    cat crypto-config/hosts
}

######## START #######
main