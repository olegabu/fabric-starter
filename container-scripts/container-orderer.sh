#!/usr/bin/env bash

: ${SYSTEM_CHANNEL_ID:=orderer-system-channel}
: ${DOMAIN:=example.com}
: ${RAFT_NODES_COUNT:=1}
: ${RAFT_NODES_NUMBERING_START:=1}
: ${CONSENTER_ID:=1}
: ${ORDERER_PROFILE:=Solo}
: ${ORDERER_NAME_PREFIX:=raft}

export ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} RAFT_NODES_COUNT RAFT_NODES_NUMBERING_START ORDERER_NAME_PREFIX


touch crypto-config/hosts


function main() {
    echo "DOMAIN=$DOMAIN, ORDERER_NAME=$ORDERER_NAME, ORDERER_DOMAIN=$ORDERER_DOMAIN, ORDERER_PROFILE=$ORDERER_PROFILE, RAFT_NODES_COUNT=${RAFT_NODES_COUNT}, RAFT_NODES_NUMBERING_START=$RAFT_NODES_NUMBERING_START, ORDERER_NAME_PREFIX=${ORDERER_NAME_PREFIX}"
    echo "ORDERER_NAMES:$ORDERER_NAMES"
    env|sort

    constructConfigTxAndCryptogenConfigs
    generateCryptoMaterialIfNotExists
    generateGenesisBlockIfNotExists
    copyWellKnownTLSCerts
    copyClientTLSCertForServingByWWW

    tree /etc/hyperledger/crypto-config/ordererOrganizations/
}

function constructConfigTxAndCryptogenConfigs() {

    if [[ -n "${ORDERER_NAMES}" ]]; then
        echo -e "\n\nUsing ORDERER_NAMES: ${ORDERER_NAMES}\n\n"
        local ordererNames
        IFS="," read -r -a ordererNames <<< ${ORDERER_NAMES}
        local start=true
        local consenterId=${CONSENTER_ID}
        for ordererName_Port in ${ordererNames[@]}; do
            local ordererConf
            IFS=':' read -r -a ordererConf <<< ${ordererName_Port}
            local ordererName=${ordererConf[0]}
            local ordererPort=${ordererConf[1]:-${ORDERER_GENERAL_LISTENPORT}}
            writeCryptogenOrgConfig ${ordererName} ${start}
            writeConfigtxOrgConfig "${ordererName}Org" ${ordererName} $ORDERER_DOMAIN ${ordererPort} ${consenterId} ${start}
            start=""
            consenterId=$((consenterId + 1))
        done
    else
        echo -e "\n\nUsing RAFT_NODES_COUNT: ${RAFT_NODES_COUNT}, ORDERER_NAME:$ORDERER_NAME\n\n"
        writeCryptogenOrgConfig "$ORDERER_NAME" true
        writeConfigtxOrgConfig "OrdererOrg" $ORDERER_NAME $ORDERER_DOMAIN ${RAFT0_PORT:-${ORDERER_GENERAL_LISTENPORT}} ${CONSENTER_ID} true
        local ind;
        for ((ind=1; ind<${RAFT_NODES_COUNT}; ind++)) do
            writeCryptogenOrgConfig "${ORDERER_NAME_PREFIX}${ind}"
            local ordererPortVar="RAFT${ind}_PORT"
            local consenterId=$((CONSENTER_ID + ind))
            writeConfigtxOrgConfig "${ORDERER_NAME_PREFIX}${ind}Org" "${ORDERER_NAME_PREFIX}${ind}" $ORDERER_DOMAIN ${!ordererPortVar:-${ORDERER_GENERAL_LISTENPORT}} ${consenterId}
        done
    fi

    PATTERN=%ORDERER_ADDRESSES% templates/templater.awk crypto-config/configtx_addresses_list.part templates/OrdererProfile_${ORDERER_PROFILE}.yaml > crypto-config/OrdererProfile_1.yaml
    PATTERN=%ORDERER_ORGS% templates/templater.awk crypto-config/configtx_orgs_list.part crypto-config/OrdererProfile_1.yaml > crypto-config/OrdererProfile_2.yaml
    PATTERN=%RAFT_CONSENTERS% templates/templater.awk crypto-config/configtx_consenters_list.part crypto-config/OrdererProfile_2.yaml > crypto-config/OrdererProfile.yaml

    envsubst < "templates/configtx-template-dynamic.yaml" > "crypto-config/configtx_1.yaml"
    PATTERN=%ORGS_DEFINITIONS% templates/templater.awk crypto-config/configtx_org_definitions.part crypto-config/configtx_1.yaml > crypto-config/configtx.yaml
    cat crypto-config/OrdererProfile.yaml >> crypto-config/configtx.yaml

    envsubst < "templates/cryptogen-orderer-template.yaml" > "crypto-config/cryptogen-orderer.yaml"
    cat crypto-config/cryptogen-orderer-spec.yaml >>  "crypto-config/cryptogen-orderer.yaml"

}

function generateCryptoMaterialIfNotExists() {
    if [ ! -f "crypto-config/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN/msp/admincerts/Admin@$ORDERER_DOMAIN-cert.pem" ]; then
        echo "Crypto-config not exists. File does not exists: crypto-config/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN/msp/admincerts/Admin@$ORDERER_DOMAIN-cert.pem"
        echo "Generating orderer MSP."
        rm -rf crypto-config/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN
        cryptogen generate --config=crypto-config/cryptogen-orderer.yaml
    else
        echo "Orderer MSP exists. Generation skipped".
    fi
}

function writeCryptogenOrgConfig() {
    local ordererName=${1:?Orderer name is required}
    local renewFiles=${2}
    local cryptogenFile=crypto-config/cryptogen-orderer-spec.yaml
    echo -e "\n\n\tWriting cryptogen hostname for: $ordererName, start new file:$renewFiles"
    if [[ ${renewFiles} ]]; then
        touch ${cryptogenFile} && truncate -s 0 ${cryptogenFile}
    fi
    ordererName=$ordererName   envsubst >> ${cryptogenFile} <<  "    END"
        - Hostname: ${ordererName}
    END
#    stdbuf -oL
}

function writeConfigtxOrgConfig() {
    local aliasName=${1:?Orderer name is required}
    local ordererName=${2:?Orderer name is required}
    local ordererDomain=${3:?Orderer domain is required}
    local ordererPort=${4:?Orderer domain is required}
    local consenterId=${5:-1}
    local renewFiles=${6}

    local orgDefinitionsFile=${7:-crypto-config/configtx_org_definitions.part}
    local orgsListFile=${8:-crypto-config/configtx_orgs_list.part}
    local addressesListFile=${9:-crypto-config/configtx_addresses_list.part}
    local consentersListFile=${10:-crypto-config/configtx_consenters_list.part}

    mkdir -p crypto-config/configtx/
    if [[ ${renewFiles} ]]; then
        touch ${orgDefinitionsFile} && truncate -s 0 ${orgDefinitionsFile}
        touch ${orgsListFile} && truncate -s 0 ${orgsListFile}
        touch ${addressesListFile} && truncate -s 0 ${addressesListFile}
        touch ${consentersListFile} && truncate -s 0 ${consentersListFile}
    fi

    echo "Writing ${orgDefinitionsFile}"
    aliasName=$aliasName ordererName=$ordererName ordererDomain=$ordererDomain \
    envsubst >> ${orgDefinitionsFile} <<  "    END"
    - &${aliasName}
        Name: $ordererName
        ID: $ordererName.$ordererDomain
        MSPDir: ordererOrganizations/${ordererDomain}/msp
        Policies:
            Readers:
                Type: Signature
                Rule: "OR('$ordererName.$ordererDomain.member')"
            Writers:
                Type: Signature
                Rule: "OR('$ordererName.$ordererDomain.member')"
            Admins:
                Type: Signature
                Rule: "OR('$ordererName.$ordererDomain.admin')"
            Endorsement:
                Type: Signature
                Rule: "OR('$ordererName.$ordererDomain.member')"
    END
    #stdbuf -oL
    echo "" >> ${orgDefinitionsFile}

    echo "Writing ${orgsListFile}"
    aliasName=$aliasName envsubst >> ${orgsListFile} <<  "    END"
          - <<: *${aliasName}
    END
#                stdbuf -oL

    echo "Writing ${addressesListFile}"
    #stdbuf -oL
    ordererName=$ordererName ordererDomain=$ordererDomain ordererPort=$ordererPort \
    envsubst >> ${addressesListFile} <<  "    END"
                - ${ordererName}.$ordererDomain:${ordererPort}

    END

    echo "Writing ${consentersListFile}"
    #stdbuf -oL
    ordererName=$ordererName ordererDomain=$ordererDomain ordererPort=$ordererPort consenterId=$consenterId \
    envsubst >> ${consentersListFile} <<  "    END"
                - Host: ${ordererName}.${ordererDomain}
                  Port: ${ordererPort}
                  ClientTLSCert: ordererOrganizations/${ordererDomain}/orderers/${ordererName}.${ordererDomain}/tls/server.crt
                  ServerTLSCert: ordererOrganizations/${ordererDomain}/orderers/${ordererName}.${ordererDomain}/tls/server.crt
                  MSPID: ${ordererName}.${ordererDomain}
                  Identity: ordererOrganizations/${ordererDomain}/orderers/${ordererName}.${ordererDomain}/msp/signcerts/${ordererName}.${ordererDomain}-cert.pem
                  ConsenterId: $consenterId
    END
}

function generateGenesisBlockIfNotExists() {
    if [ ! -f "crypto-config/configtx/$ORDERER_DOMAIN/genesis.pb" ]; then
        echo "Generating genesis configtx."
        mkdir -p crypto-config/configtx/$ORDERER_DOMAIN
        configtxgen -configPath crypto-config/ -outputBlock crypto-config/configtx/$ORDERER_DOMAIN/genesis.pb -profile ${ORDERER_PROFILE} -channelID ${SYSTEM_CHANNEL_ID}
    else
        echo "Genesis configtx exists. Generation skipped".
    fi
}

function copyWellKnownTLSCerts() {
    echo "Copying well-known tls certs to nginx "
    mkdir -p crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/.well-known
    cp crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/tlscacerts/tlsca.$ORDERER_DOMAIN-cert.pem crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/.well-known/msp-admin.pem 2>/dev/null
    cp crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/tlscacerts/tlsca.$ORDERER_DOMAIN-cert.pem crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/.well-known/tlsca-cert.pem 2>/dev/null
}

function copyClientTLSCertForServingByWWW() {
    tlsCert="crypto-config/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN/tls/server.crt"

    tlsNginxFolder=crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
    echo "Copying tls certs to nginx served folder $tlsCert"
    mkdir -p ${tlsNginxFolder}
    cp "${tlsCert}" "${tlsNginxFolder}"

    #deprecated
    tlsNginxFolder=crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
    echo "Copying tls certs to nginx served folder $tlsCert"
    mkdir -p ${tlsNginxFolder}
    cp "${tlsCert}" "${tlsNginxFolder}"
    ###########

    set -x
    tlsNginxFolder=crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
    mkdir -p ${tlsNginxFolder}
    cp "${tlsCert}" "${tlsNginxFolder}"

    mkdir -p crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp
    cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/admincerts crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp 2>/dev/null
    cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/cacerts crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp 2>/dev/null
    cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/tlscacerts crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp 2>/dev/null
    set +x

    if [[ -n "{ORG}" && -d "crypto-config/peerOrganizations/${ORG}.${DOMAIN}/msp/" ]]; then
        echo "Copying tls certs to peerOrganizations nginx served folder $tlsCert"

        set -x
        #deprecated:
        tlsNginxFolder=crypto-config/peerOrganizations/${ORG}.${DOMAIN}/msp/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
        mkdir -p ${tlsNginxFolder}
        cp "${tlsCert}" "${tlsNginxFolder}"

        cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/* crypto-config/peerOrganizations/$ORG.$DOMAIN/msp 2>/dev/null
        ###########
        set +x
    fi
}

main