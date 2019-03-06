#!/usr/bin/env bash


: ${DOMAIN:="example.com"}
: ${ORG:="org1"}
: ${SYSTEM_CHANNEL_ID:=orderer-system-channel}

export ORG DOMAIN SYSTEM_CHANNEL_ID

: ${ORDERER_TLSCA_CERT_OPTS=" --tls --cafile /etc/hyperledger/crypto-config/ordererOrganizations/${DOMAIN}/msp/tlscacerts/tlsca.${DOMAIN}-cert.pem"}


function certificationsToEnv() {
    local org=$1
    local mspDir="crypto-config/peerOrganizations/${org}.${DOMAIN:-example.com}/msp"
    if [ "${org}" == "orderer" ]; then
        mspDir="crypto-config/ordererOrganizations/${DOMAIN:-example.com}/msp";
        org=""
    fi
    export ORG_ADMIN_CERT=`cat ${mspDir}/admincerts/Admin@${org}${org:+.}${DOMAIN:-example.com}-cert.pem | base64 -w 0` \
      && export ORG_ROOT_CERT=`cat ${mspDir}/cacerts/ca.${org}${org:+.}${DOMAIN:-example.com}-cert.pem | base64 -w 0` \
      && export ORG_TLS_ROOT_CERT=`cat ${mspDir}/tlscacerts/tlsca.${org}${org:+.}${DOMAIN:-example.com}-cert.pem | base64 -w 0`
}

function fetchChannelConfigBlock() {
    local channel=${1:?"Channel name must be specified"}
    local blockNum=${2:-config}

    mkdir -p crypto-config/configtx
    peer channel fetch $blockNum crypto-config/configtx/${channel}.pb -o orderer.$DOMAIN:7050 -c ${channel} ${ORDERER_TLSCA_CERT_OPTS}
}

function txTranslateChannelConfigBlock() {
    local channel=$1
    fetchChannelConfigBlock $channel
    configtxlator proto_decode --type 'common.Block' --input=crypto-config/configtx/${channel}.pb --output=crypto-config/configtx/${channel}.json
    jq .data.data[0].payload.data.config crypto-config/configtx/${channel}.json > crypto-config/configtx/config.json
}

function updateChannelGroupConfigForOrg() {
    local org=$1
    local templateFileOfUpdate=$2
    local exportEnvironment=$3
    local exportEnvironment="export NEWORG=${org} ${exportEnvironment:+&&} ${exportEnvironment}"

    export NEWORG=${org}
    envsubst < "${templateFileOfUpdate}" > "crypto-config/configtx/new_config_${org}.json" # TODO: check where "$exportEnvironment" used and apply as needed
    jq -s '.[0] * {"channel_group":{"groups":.[1]}}' crypto-config/configtx/config.json crypto-config/configtx/new_config_${org}.json > crypto-config/configtx/updated_config.json
}


function createConfigUpdateEnvelope() {
    local channel=$1
    local configJson=${2:-'crypto-config/configtx/config.json'}
    local updatedConfigJson=${3:-'crypto-config/configtx/updated_config.json'}

    echo " >> Prepare config update from $org for channel $channel"
    configtxlator proto_encode --type 'common.Config' --input=${configJson} --output=config.pb \
    && configtxlator proto_encode --type 'common.Config' --input=${updatedConfigJson} --output=updated_config.pb \
    && configtxlator compute_update --channel_id=$channel --original=config.pb  --updated=updated_config.pb --output=update.pb \
    && configtxlator proto_decode --type 'common.ConfigUpdate' --input=update.pb --output=crypto-config/configtx/update.json && chown $UID crypto-config/configtx/update.json

    echo "{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"$channel\",\"type\":2}},\"data\":{\"config_update\":`cat crypto-config/configtx/update.json`}}}" | jq . > crypto-config/configtx/update_in_envelope.json
    configtxlator proto_encode --type 'common.Envelope' --input=crypto-config/configtx/update_in_envelope.json --output=update_in_envelope.pb
    echo " >> $org is sending channel update update_in_envelope.pb with $d by $command"
    peer channel update -f update_in_envelope.pb -c ${channel} -o orderer.${DOMAIN}:7050 ${ORDERER_TLSCA_CERT_OPTS}
}

function updateChannelConfig() {
    local channel=${1:?Channel to be updated must be specified}
    local org=${2:?Org to be updated must be specified}
    local templateFile=${3:?template file must be specified}
    local exportEnv=$4
    txTranslateChannelConfigBlock "$channel"
    updateChannelGroupConfigForOrg "$org" "$templateFile" "$exportEnv"
    createConfigUpdateEnvelope $channel
}


function updateConsortium() {
    local org=${1:?Org to be added to consortium must be specified}
    local channel=${2:?System channel must be specified}
    local updateTemplateFile=${3:-./templates/Consortium.json}
    local consortiumName=${4:-SampleConsortium}

    export CONSORTIUM_NAME=${consortiumName} && $(certificationsToEnv $org)
    updateChannelConfig $channel $org "$updateTemplateFile" "$exportEnv"
}
