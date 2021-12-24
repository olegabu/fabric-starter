#!/usr/bin/env bash

: ${SYSTEM_CHANNEL_ID:=orderer-system-channel}
: ${DOMAIN:=example.com}
: ${RAFT_NODES_COUNT:=1}
: ${RAFT_NODES_NUMBERING_START:=1}
: ${CONSENTER_ID:=1}
: ${ORDERER_PROFILE:=Solo}
: ${ORDERER_NAME_PREFIX:=raft}
: ${ORDERER_BATCH_TIMEOUT:=2}

export INTERNAL_DOMAIN=${INTERNAL_DOMAIN:-${DOMAIN}}

export TMP_DIR=${TMP_DIR:-/etc/hyperledger}/crypto-config
mkdir -p ${TMP_DIR}

export ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} RAFT_NODES_COUNT RAFT_NODES_NUMBERING_START ORDERER_NAME_PREFIX ORDERER_BATCH_TIMEOUT


touch ${TMP_DIR}/hosts


function main() {
    echo "DOMAIN=$DOMAIN, ORDERER_NAME=$ORDERER_NAME, ORDERER_DOMAIN=$ORDERER_DOMAIN, ORDERER_PROFILE=$ORDERER_PROFILE, RAFT_NODES_COUNT=${RAFT_NODES_COUNT}, RAFT_NODES_NUMBERING_START=$RAFT_NODES_NUMBERING_START, ORDERER_NAME_PREFIX=${ORDERER_NAME_PREFIX}"
    echo "ORDERER_NAMES:$ORDERER_NAMES, INTERNAL_DOMAIN: $INTERNAL_DOMAIN"
    env|sort

    constructConfigTxAndCryptogenConfigs
    generateCryptoMaterialIfNotExists
    generateGenesisBlockIfNotExists
    copyWellKnownTLSCerts
    copyClientTLSCertForServingByWWW

    tree ${TMP_DIR}/
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
        writeConfigtxOrgConfig "OrdererOrg" $ORDERER_NAME $ORDERER_DOMAIN ${RAFT0_CONSENTER_PORT:-${ORDERER_GENERAL_LISTENPORT}} ${CONSENTER_ID} true
        local ind;
        for ((ind=1; ind<${RAFT_NODES_COUNT}; ind++)) do
            writeCryptogenOrgConfig "${ORDERER_NAME_PREFIX}${ind}"
            local ordererPortVar="RAFT${ind}_CONSENTER_PORT"
            local consenterId=$((CONSENTER_ID + ind))
            writeConfigtxOrgConfig "${ORDERER_NAME_PREFIX}${ind}Org" "${ORDERER_NAME_PREFIX}${ind}" $ORDERER_DOMAIN ${!ordererPortVar:-${ORDERER_GENERAL_LISTENPORT}} ${consenterId}
        done
    fi

    PATTERN=%ORDERER_ADDRESSES% templates/templater.awk ${TMP_DIR}/configtx_addresses_list.part templates/OrdererProfile_${ORDERER_PROFILE}.yaml > ${TMP_DIR}/OrdererProfile_1.yaml
    PATTERN=%ORDERER_ORGS% templates/templater.awk ${TMP_DIR}/configtx_orgs_list.part ${TMP_DIR}/OrdererProfile_1.yaml > ${TMP_DIR}/OrdererProfile_2.yaml
    PATTERN=%RAFT_CONSENTERS% templates/templater.awk ${TMP_DIR}/configtx_consenters_list.part ${TMP_DIR}/OrdererProfile_2.yaml > ${TMP_DIR}/OrdererProfile.yaml

    envsubst < "templates/configtx-template-dynamic.yaml" > "${TMP_DIR}/configtx_1.yaml"
    PATTERN=%ORGS_DEFINITIONS% templates/templater.awk ${TMP_DIR}/configtx_org_definitions.part ${TMP_DIR}/configtx_1.yaml > ${TMP_DIR}/configtx.yaml
    cat ${TMP_DIR}/OrdererProfile.yaml >> ${TMP_DIR}/configtx.yaml

    envsubst < "templates/cryptogen-orderer-template.yaml" > "${TMP_DIR}/cryptogen-orderer.yaml"
    cat ${TMP_DIR}/cryptogen-orderer-spec.yaml >>  "${TMP_DIR}/cryptogen-orderer.yaml"

}

function generateCryptoMaterialIfNotExists() {
    if [ ! -f "${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN/msp/admincerts/Admin@$ORDERER_DOMAIN-cert.pem" ]; then
        echo "Crypto-config not exists. File does not exists: ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN/msp/admincerts/Admin@$ORDERER_DOMAIN-cert.pem"
        echo "Generating orderer MSP."
        set -x
        rm -rf ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN
        mkdir ${TMP_DIR}/temp
        cryptogen generate --config=${TMP_DIR}/cryptogen-orderer.yaml --output="${TMP_DIR}/temp"
        sleep 1
        cp -r ${TMP_DIR}/temp/* "${TMP_DIR}"
        rm -rf "${TMP_DIR}/temp"
        set +x
    else
        echo "Orderer MSP exists. Generation skipped".
    fi
}

function writeCryptogenOrgConfig() {
    local ordererName=${1:?Orderer name is required}
    local renewFiles=${2}
    local cryptogenFile=${TMP_DIR}/cryptogen-orderer-spec.yaml
    echo -e "\n\n\tWriting cryptogen hostname for: $ordererName, start new file:$renewFiles"
    if [[ ${renewFiles} ]]; then
        touch ${cryptogenFile} && truncate -s 0 ${cryptogenFile}
    fi
    ordererName=$ordererName   envsubst >> ${cryptogenFile} <<  "    END"
        - Hostname: ${ordererName}
    END
    if [[ -n "${INTERNAL_DOMAIN}" ]]; then
    ordererName=$ordererName   envsubst >> ${cryptogenFile} <<  "    END"
          SANS:
            - ${ordererName}.${INTERNAL_DOMAIN}
    END

    fi
#    stdbuf -oL
}

function writeConfigtxOrgConfig() {
    local aliasName=${1:?Orderer name is required}
    local ordererName=${2:?Orderer name is required}
    local ordererDomain=${3:?Orderer domain is required}
    local ordererPort=${4:?Orderer domain is required}
    local consenterId=${5:-1}
    local renewFiles=${6}

    local orgDefinitionsFile=${7:-${TMP_DIR}/configtx_org_definitions.part}
    local orgsListFile=${8:-${TMP_DIR}/configtx_orgs_list.part}
    local addressesListFile=${9:-${TMP_DIR}/configtx_addresses_list.part}
    local consentersListFile=${10:-${TMP_DIR}/configtx_consenters_list.part}

    mkdir -p ${TMP_DIR}/configtx/
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
        MSPDir: ${TMP_DIR}/ordererOrganizations/${ordererDomain}/msp
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
#                  MSPID: ${ordererName}.${ordererDomain}
#                  Identity: ${TMP_DIR}/ordererOrganizations/${ordererDomain}/orderers/${ordererName}.${ordererDomain}/msp/signcerts/${ordererName}.${ordererDomain}-cert.pem
#                  ConsenterId: $consenterId
    END
}

function generateGenesisBlockIfNotExists() {
    if [ ! -f "${TMP_DIR}/configtx/$ORDERER_DOMAIN/genesis.pb" ]; then
        echo "Generating genesis configtx."
        mkdir -p ${TMP_DIR}/configtx/$ORDERER_DOMAIN
        configtxgen -configPath ${TMP_DIR}/ -outputBlock ${TMP_DIR}/configtx/$ORDERER_DOMAIN/genesis.pb -profile ${ORDERER_PROFILE} -channelID ${SYSTEM_CHANNEL_ID}
    else
        echo "Genesis configtx exists. Generation skipped".
    fi
}

function copyWellKnownTLSCerts() {
    echo "Copying well-known tls certs to nginx "
    mkdir -p ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/msp/.well-known
    cp ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/msp/tlscacerts/tlsca.$ORDERER_DOMAIN-cert.pem ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/msp/.well-known/msp-admin.pem 2>/dev/null
    cp ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/msp/tlscacerts/tlsca.$ORDERER_DOMAIN-cert.pem ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/msp/.well-known/tlsca-cert.pem 2>/dev/null
}

function copyClientTLSCertForServingByWWW() {
    tlsCert="crypto-config/ordererOrganizations/$ORDERER_DOMAIN/orderers/${ORDERER_NAME}.$ORDERER_DOMAIN/tls/server.crt"

    tlsNginxFolder=${TMP_DIR}/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
    echo "Copying tls certs to nginx served folder $tlsCert"
    mkdir -p ${tlsNginxFolder}
    cp "${tlsCert}" "${tlsNginxFolder}"

    #deprecated
    tlsNginxFolder=${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/msp/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
    echo "Copying tls certs to nginx served folder $tlsCert"
    mkdir -p ${tlsNginxFolder}
    cp "${tlsCert}" "${tlsNginxFolder}"
    ###########

    set -x
    tlsNginxFolder=${TMP_DIR}/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
    mkdir -p ${tlsNginxFolder}
    cp "${tlsCert}" "${tlsNginxFolder}"

    mkdir -p ${TMP_DIR}/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp
    cp -r ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/msp/admincerts crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp 2>/dev/null
    cp -r ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/msp/cacerts crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp 2>/dev/null
    cp -r ${TMP_DIR}/ordererOrganizations/$ORDERER_DOMAIN/msp/tlscacerts crypto-config/node-certs/${ORDERER_NAME}.$ORDERER_DOMAIN/msp 2>/dev/null
    set +x

    if [[ -n "{ORG}" && -d "crypto-config/peerOrganizations/${ORG}.${DOMAIN}/msp/" ]]; then
        echo "Copying tls certs to peerOrganizations nginx served folder $tlsCert"

        set -x
        #deprecated:
#        tlsNginxFolder=crypto-config/peerOrganizations/${ORG}.${DOMAIN}/msp/${ORDERER_NAME}.$ORDERER_DOMAIN/tls
#        mkdir -p ${tlsNginxFolder}
#        cp "${tlsCert}" "${tlsNginxFolder}"

#        cp -r crypto-config/ordererOrganizations/$ORDERER_DOMAIN/msp/* crypto-config/peerOrganizations/$ORG.$DOMAIN/msp 2>/dev/null
        ###########
        set +x
    fi
}

main