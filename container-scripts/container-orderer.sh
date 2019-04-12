#!/usr/bin/env bash
: ${SYSTEM_CHANNEL_ID:=orderer-system-channel}
: ${ORDERER_CRYPTO_TEMPLATE:=cryptogen-orderer-template.yaml}
: ${ORDERERS_COUNT:=1}
: ${ORDERER_DOMAIN:=${DOMAIN:-example.com}}
: ${ORDERER_NAME:=orderer}

tree crypto-config

if [ ! -f "crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/orderers/${ORDERER_NAME}.$DOMAIN/msp/admincerts/Admin@${ORDERER_DOMAIN}-cert.pem" ]; then
    echo "Generation orderer MSP using templates/${ORDERER_CRYPTO_TEMPLATE}"

    envsubst < "templates/${ORDERER_CRYPTO_TEMPLATE}" > "crypto-config/cryptogen-orderer.yaml"
    rm -rf crypto-config/ordererOrganizations
    cryptogen generate --config=crypto-config/cryptogen-orderer.yaml

    mkdir -p crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/msp/well-known
    cp crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${ORDERER_DOMAIN}-cert.pem crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/msp/well-known/msp-admin.pem 2>/dev/null
    cp crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${ORDERER_DOMAIN}-cert.pem crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/msp/well-known/tlsca-cert.pem 2>/dev/null
else
    echo "Orderer MSP for domain ${ORDERER_DOMAIN} exists. Generation skipped".
fi

if [ ! -f "crypto-config/configtx/genesis.pb" ]; then
    echo "Generation genesis configtx."
    envsubst < "templates/configtx-template.yaml" > "crypto-config/configtx.yaml"
    mkdir -p crypto-config/configtx
    configtxgen -configPath crypto-config/ -outputBlock crypto-config/configtx/genesis.pb -profile OrdererGenesis -channelID ${SYSTEM_CHANNEL_ID}
else
    echo "Genesis configtx exists. Generation skipped".
fi

if [ ! -f "crypto-config/hosts_orderer" ]; then
    echo "Generating crypto-config/hosts_orderer"
    echo -e "#generated at bootstrap as part of crypto- and meta-information generation" > crypto-config/hosts_orderer
else
    echo "crypto-config/hosts_orderer file exists. Generation skipped."
fi
cat crypto-config/hosts_orderer
