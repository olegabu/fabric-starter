#!/usr/bin/env bash
: ${SYSTEM_CHANNEL_ID:=orderer-system-channel}

tree crypto-config

if [ ! -f "crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/msp/admincerts/Admin@$DOMAIN-cert.pem" ]; then
    echo "Generation orderer MSP."

    envsubst < "templates/cryptogen-orderer-template.yaml" > "crypto-config/cryptogen-orderer.yaml"
    rm -rf crypto-config/ordererOrganizations
    cryptogen generate --config=crypto-config/cryptogen-orderer.yaml

    mkdir -p crypto-config/ordererOrganizations/$DOMAIN/msp/well-known
    cp crypto-config/ordererOrganizations/$DOMAIN/msp/tlscacerts/tlsca.$DOMAIN-cert.pem crypto-config/ordererOrganizations/$DOMAIN/msp/well-known/msp-admin.pem 2>/dev/null
    cp crypto-config/ordererOrganizations/$DOMAIN/msp/tlscacerts/tlsca.$DOMAIN-cert.pem crypto-config/ordererOrganizations/$DOMAIN/msp/well-known/tlsca-cert.pem 2>/dev/null
else
    echo "Orderer MSP exists. Generation skipped".
fi

if [ ! -f "crypto-config/configtx/genesis.pb" ]; then
    echo "Generation genesis configtx."
    envsubst < "templates/configtx-template.yaml" > "crypto-config/configtx.yaml"
    mkdir -p crypto-config/configtx
    configtxgen -configPath crypto-config/ -outputBlock crypto-config/configtx/genesis.pb -profile OrdererGenesis -channelID ${SYSTEM_CHANNEL_ID}
else
    echo "Genesis configtx exists. Generation skipped".
fi

