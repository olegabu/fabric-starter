#!/usr/bin/env bash

: ${DOMAIN:="example.com"}
: ${ORG:="org1"}
: ${WGET_OPTS:="--verbose -N"}
: ${WWW_PORT:=8081}

function runCLI() {
   command="$1"
   [ -n "$EXECUTE_BY_ORDERER" ] && composeTemplateSuffix="orderer" || composeTemplateSuffix="peer"
   composeTemplateFile="docker-compose/docker-compose-$composeTemplateSuffix.yaml"
   service="cli.$composeTemplateSuffix"
   echo "CLI exec:$composeTemplateFile:$service: $command"

   [ -n "$EXECUTE_BY_ORDERER" ] && checkContainer="cli.$DOMAIN" || checkContainer="cli.$ORG.$DOMAIN"
   cliId=`docker ps --filter name=$checkContainer -q`
   [ -n "$cliId" ] && composeCommand="exec" || composeCommand="run"

   docker-compose --file ${composeTemplateFile} ${composeCommand} ${service} bash -c "$command"
}

function downloadMSP() {
    org=$1
    [ -n "$EXECUTE_BY_ORDERER" ] && mspSubPath="$org.$DOMAIN" && port=WWW_PORT ||  mspSubPath="$DOMAIN" && port=8080
#TODO:
#    wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/${mspSubPath}/msp/admincerts http://www.${mspSubPath}:$port/msp/admincerts/Admin@${mspSubPath}-cert.pem
#    wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/${mspSubPath}/msp/cacerts http://www.${mspSubPath}:$port/msp/cacerts/ca.${mspSubPath}-cert.pem
#    wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/${mspSubPath}/msp/tlscacerts http://www.${mspSubPath}:$port/msp/tlscacerts/tlsca.${mspSubPath}-cert.pem
}

function certificationsEnv() {
  newOrg=$1
  echo "export ORG_ADMIN_CERT=`cat crypto-config/peerOrganizations/${newOrg}.${DOMAIN:-example.com}/msp/admincerts/Admin@${newOrg}.${DOMAIN:-example.com}-cert.pem | base64 -w 0` \
  && export ORG_ROOT_CERT=`cat crypto-config/peerOrganizations/${newOrg}.${DOMAIN:-example.com}/msp/cacerts/ca.${newOrg}.${DOMAIN:-example.com}-cert.pem | base64 -w 0` \
  && export ORG_TLS_ROOT_CERT=`cat crypto-config/peerOrganizations/${newOrg}.${DOMAIN:-example.com}/msp/tlscacerts/tlsca.${newOrg}.${DOMAIN:-example.com}-cert.pem | base64 -w 0`"
}

function fetchChannelConfigBlock() {
  channel=${1:?"Channel name must be specified"}
  blockNum=${2:-config}
  runCLI "peer channel fetch $blockNum crypto-config/configtx/${channel}.pb -o orderer.$DOMAIN:7050 -c ${channel}  \
     --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt && chown $UID -R crypto-config/"
}

function txTranslateChannelConfigBlock() {
  channel=$1
  fetchChannelConfigBlock $channel
  runCLI "configtxlator proto_decode --type 'common.Block' --input=crypto-config/configtx/${channel}.pb --output=crypto-config/configtx/${channel}.json \
     &&  chown $UID crypto-config/configtx/${channel}.json \
     && jq .data.data[0].payload.data.config crypto-config/configtx/${channel}.json > crypto-config/configtx/config.json"
}

function updateChannelGroupConfigForNewOrg() {
    newOrg=$1
    templateFileOfUpdate=$2
    exportEnvironment=$3
    exportEnvironment="export NEWORG=${newOrg} ${exportEnvironment:+&&} ${exportEnvironment}"

    runCLI "${exportEnvironment} \
    && envsubst < ${templateFileOfUpdate} > crypto-config/configtx/new_config_${newOrg}.json \
    && jq -s '.[0] * {\"channel_group\":{\"groups\":.[1]}}' crypto-config/configtx/config.json crypto-config/configtx/new_config_${newOrg}.json > crypto-config/configtx/updated_config.json"
}


function createConfigUpdateEnvelope() {
 channel=$1
 configJson=${2:-'crypto-config/configtx/config.json'}
 updatedConfigJson=${3:-'crypto-config/configtx/updated_config.json'}

 echo " >> Prepare config update from $org for channel $channel"
 runCLI "configtxlator proto_encode --type 'common.Config' --input=${configJson} --output=config.pb \
    && configtxlator proto_encode --type 'common.Config' --input=${updatedConfigJson} --output=updated_config.pb \
    && configtxlator compute_update --channel_id=$channel --original=config.pb  --updated=updated_config.pb --output=update.pb \
    && configtxlator proto_decode --type 'common.ConfigUpdate' --input=update.pb --output=crypto-config/configtx/update.json && chown $UID crypto-config/configtx/update.json"
  runCLI "echo '{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"$channel\",\"type\":2}},\"data\":{\"config_update\":'\`cat crypto-config/configtx/update.json\`'}}}' | jq . > crypto-config/configtx/update_in_envelope.json"
  runCLI "configtxlator proto_encode --type 'common.Envelope' --input=crypto-config/configtx/update_in_envelope.json --output=update_in_envelope.pb"
  echo " >> $org is sending channel update update_in_envelope.pb with $d by $command"
  runCLI "peer channel update -f update_in_envelope.pb -c $channel -o orderer.$DOMAIN:7050 --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
}


function updateConsortium() {
  newOrg=${1:?Org to be added to consortium must be specified}
  channel=${2:?System channel must be specified}
  consortiumName=${3:-SampleConsortium}

  txTranslateChannelConfigBlock "$channel"
  exportEnv="export CONSORTIUM_NAME=${consortiumName} && $(certificationsEnv $newOrg)"
  updateChannelGroupConfigForNewOrg "$newOrg" ./templates/Consortium.json "$exportEnv"
  createConfigUpdateEnvelope orderer-system-channel
}

function updateChannelModificationPolicy() {
  channel=${1:?"Channel must be specified"}
  txTranslateChannelConfigBlock "$channel"
  updateChannelGroupConfigForNewOrg $ORG ./templates/ModPolicyOrgOnly.json
  createConfigUpdateEnvelope $channel
}

function addOrgToChannel() {
  newOrg=${1:?"New Org must be specified"}
  channel=${2:?"Channel must be specified"}
  txTranslateChannelConfigBlock "$channel"
  updateChannelGroupConfigForNewOrg $newOrg ./templates/NewOrg.json  "$(certificationsEnv $newOrg)"
  createConfigUpdateEnvelope $channel
}

function joinChannel() {

  channelOwnerOrg=${1:?Channel owner org must be specified}
  channel=${2:?Channel name must be specified}

  fetchChannelConfigBlock $channel "0"

  runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer channel join -b crypto-config/configtx/$channel.pb"
  runCLI "CORE_PEER_ADDRESS=peer1.$ORG.$DOMAIN:7051 peer channel join -b crypto-config/configtx/$channel.pb"
}
