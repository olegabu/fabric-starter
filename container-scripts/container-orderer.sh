#!/usr/bin/env bash

: ${SYSTEM_CHANNEL_ID:=orderer-system-channel}
: ${DOMAIN:=example.com}

export ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN}

touch crypto-config/hosts


function main() {
    echo "DOMAIN=$DOMAIN, ORDERER_NAME=$ORDERER_NAME, ORDERER_DOMAIN=$ORDERER_DOMAIN, ORDERER_GENESIS_PROFILE=$ORDERER_GENESIS_PROFILE, RAFT_NODES_COUNT=${RAFT_NODES_COUNT}, ORDERER_NAME_PREFIX=${ORDERER_NAME_PREFIX}"
    env|sort

    generateCryptoMaterialIfNotExists
    generateGenesisBlock
    copyWellKnownTLSCerts
    copyClientTLSCertForServingByWWW

    tree /etc/hyperledger/crypto-config/ordererOrganizations/
}

function generateCryptoMaterialIfNotExists() {
    if [ ! -f "crypto-config/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN/msp/admincerts/Admin@$ORDERER_DOMAIN-cert.pem" ]; then
        echo "File does not exists: crypto-config/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN/msp/admincerts/Admin@$ORDERER_DOMAIN-cert.pem"
        echo "Generation orderer MSP."

        cryptogenTemplate="templates/cryptogen-orderer-template.yaml"
        [ -f "templates/cryptogen-${ORDERER_GENESIS_PROFILE}-template.yaml" ] && cryptogenTemplate="templates/cryptogen-${ORDERER_GENESIS_PROFILE}-template.yaml"
        envsubst < "${cryptogenTemplate}" > "crypto-config/cryptogen-orderer.yaml"
        rm -rf crypto-config/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN
        cryptogen generate --config=crypto-config/cryptogen-orderer.yaml
        tree crypto-config/ordererOrganizations
    else
        echo "Orderer MSP exists. Generation skipped".
    fi
}

function generateGenesisBlock() {
    set -x
    if [ ! -f "crypto-config/configtx/$ORDERER_DOMAIN/genesis.pb" ]; then
        echo "Generation genesis configtx."
        envsubst < "templates/configtx-template.yaml" > "crypto-config/configtx.yaml"
        mkdir -p crypto-config/configtx/$ORDERER_DOMAIN
        configtxgen -configPath crypto-config/ -outputBlock crypto-config/configtx/$ORDERER_DOMAIN/genesis.pb -profile ${ORDERER_GENESIS_PROFILE} -channelID ${SYSTEM_CHANNEL_ID}
    else
        echo "Genesis configtx exists. Generation skipped".
    fi
    set +x
}

function copyWellKnownTLSCerts() {
    echo "Copying well-known tls certs to nginx "
    mkdir -p crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/.well-known
    cp crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/tlscacerts/tlsca.$ORDERER_DOMAIN-cert.pem crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/.well-known/msp-admin.pem 2>/dev/null
    cp crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/tlscacerts/tlsca.$ORDERER_DOMAIN-cert.pem crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/.well-known/tlsca-cert.pem 2>/dev/null
}

function copyClientTLSCertForServingByWWW() {
    tlsCert="crypto-config/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN/tls/server.crt"
    tlsNginxFolder=crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
    echo "Copying tls certs to nginx served folder $tlsCert"
    mkdir -p ${tlsNginxFolder}
    cp "${tlsCert}" "${tlsNginxFolder}"

    if [[ -n "{ORG}" && -d "crypto-config/peerOrganizations/${ORG}.${DOMAIN}/msp/" ]]; then
        set -x
        echo "Copying tls certs to peerOrganizations nginx served folder $tlsCert"
        tlsNginxFolder=crypto-config/peerOrganizations/${ORG}.${DOMAIN}/msp/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
        mkdir -p ${tlsNginxFolder}
        cp "${tlsCert}" "${tlsNginxFolder}"

        cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/* crypto-config/peerOrganizations/$ORG.$DOMAIN/msp 2>/dev/null
        set +x
    fi
}

main