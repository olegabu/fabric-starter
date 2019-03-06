#!/usr/bin/env bash
: ${SYSTEM_CHANNEL_ID:=orderer-system-channel}

tree crypto-config

if [ ! -f "crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/msp/admincerts/Admin@$DOMAIN-cert.pem" ]; then
    echo "Generation orderer MSP."

    envsubst < "templates/cryptogen-orderer-template.yaml" > "crypto-config/cryptogen-orderer.yaml"
    rm -rf crypto-config/ordererOrganizations
    cryptogen generate --config=crypto-config/cryptogen-orderer.yaml
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

