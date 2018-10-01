#!/usr/bin/env bash

: ${DOMAIN:="example.com"}
: ${ORG:="org1"}
: ${WGET_OPTS:="--verbose -N"}
: ${WWW_PORT:=8081}

function printUsage() {
   usageMsg=$1
   exampleMsg=$2
   echo -e "\n\e[1;31mUsage:\e[m \e[1;33m$usageMsg\e[m"
   echo -e "\e[1;31mExample:\e[m \e[1;33m$exampleMsg\e[m"

}

function runCLI() {
   command="$1"

   if [ -n "$EXECUTE_BY_ORDERER" ]; then
        composeTemplateFile="docker-compose-orderer.yaml"
        service="cli.orderer"
   else
        composeTemplateFile="docker-compose.yaml"
        service="cli.peer"
   fi

   [ -n "$EXECUTE_BY_ORDERER" ] && checkContainer="cli.$DOMAIN" || checkContainer="cli.$ORG.$DOMAIN"
   cliId=`docker ps --filter name=$checkContainer -q`
   #TODO getting error No such command: run __rm
   [ -n "$cliId" ] && composeCommand="exec" || composeCommand="run"
   echo -e "\x1b[32mExecute:docker-compose -f $composeTemplateFile ${COMPOSE_FLAGS} $composeCommand $service bash -c \"$command\"\033[0m"

   docker-compose -f "${composeTemplateFile}" "${COMPOSE_FLAGS}" ${composeCommand} ${service} bash -c "$command"
}

function downloadMSP() {
    org=$1

    if [ -n "$EXECUTE_BY_ORDERER" ]; then
        mspSubPath="$org.$DOMAIN"
        orgSubPath="peerOrganizations"
    else
        [ -n "$org" ] && mspSubPath="$org.$DOMAIN" orgSubPath="peerOrganizations" || mspSubPath="$DOMAIN" orgSubPath="ordererOrganizations"
    fi
    runCLI "wget ${WGET_OPTS} --directory-prefix crypto-config/${orgSubPath}/${mspSubPath}/msp/admincerts http://www.${mspSubPath}:${WWW_PORT}/msp/admincerts/Admin@${mspSubPath}-cert.pem"
    runCLI "wget ${WGET_OPTS} --directory-prefix crypto-config/${orgSubPath}/${mspSubPath}/msp/cacerts http://www.${mspSubPath}:${WWW_PORT}/msp/cacerts/ca.${mspSubPath}-cert.pem"
    runCLI "wget ${WGET_OPTS} --directory-prefix crypto-config/${orgSubPath}/${mspSubPath}/msp/tlscacerts http://www.${mspSubPath}:${WWW_PORT}/msp/tlscacerts/tlsca.${mspSubPath}-cert.pem"
    runCLI "mkdir -p crypto-config/${orgSubPath}/${mspSubPath}/msp/tls/ \
    && cp crypto-config/${orgSubPath}/${mspSubPath}/msp/tlscacerts/tlsca.${mspSubPath}-cert.pem crypto-config/${orgSubPath}/${mspSubPath}/msp/tls/ca.crt"
}

function certificationsEnv() {
  org=$1
  echo "export ORG_ADMIN_CERT=\`cat crypto-config/peerOrganizations/${org}.${DOMAIN:-example.com}/msp/admincerts/Admin@${org}.${DOMAIN:-example.com}-cert.pem | base64 -w 0\` \
  && export ORG_ROOT_CERT=\`cat crypto-config/peerOrganizations/${org}.${DOMAIN:-example.com}/msp/cacerts/ca.${org}.${DOMAIN:-example.com}-cert.pem | base64 -w 0\` \
  && export ORG_TLS_ROOT_CERT=\`cat crypto-config/peerOrganizations/${org}.${DOMAIN:-example.com}/msp/tlscacerts/tlsca.${org}.${DOMAIN:-example.com}-cert.pem | base64 -w 0\`"
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

function updateChannelGroupConfigForOrg() {
    org=$1
    templateFileOfUpdate=$2
    exportEnvironment=$3
    exportEnvironment="export NEWORG=${org} ${exportEnvironment:+&&} ${exportEnvironment}"

    runCLI "${exportEnvironment} \
    && envsubst < ${templateFileOfUpdate} > crypto-config/configtx/new_config_${org}.json \
    && jq -s '.[0] * {\"channel_group\":{\"groups\":.[1]}}' crypto-config/configtx/config.json crypto-config/configtx/new_config_${org}.json > crypto-config/configtx/updated_config.json"
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

function updateChannelConfig() {
  org=${1:?Org to be updated must be specified}
  channel=${2:?Channel to be updated must be specified}
  templateFile=${3:?template file must be specified}
  exportEnv=$4

  txTranslateChannelConfigBlock "$channel"
  updateChannelGroupConfigForOrg "$org" "$templateFile" "$exportEnv"
  createConfigUpdateEnvelope $channel
}

function updateConsortium() {
  org=${1:?Org to be added to consortium must be specified}
  channel=${2:?System channel must be specified}
  consortiumName=${3:-SampleConsortium}

  exportEnv="export CONSORTIUM_NAME=${consortiumName} && $(certificationsEnv $org)"
  updateChannelConfig $org $channel ./templates/Consortium.json "$exportEnv"
}

function updateChannelModificationPolicy() {
  channel=${1:?"Channel must be specified"}
  updateChannelConfig $ORG $channel ./templates/ModPolicyOrgOnly.json
}

function addOrgToChannel() {
  org=${1:?"New Org must be specified"}
  channel=${2:?"Channel must be specified"}

  echo " >> Add new org '$org' to channel $channel"
  updateChannelConfig $org $channel ./templates/NewOrg.json "$(certificationsEnv $org)"
}

function joinChannel() {
  channel=${1:?Channel name must be specified}

  echo "Join $ORG to channel $channel"
  fetchChannelConfigBlock $channel "0"
  runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer channel join -b crypto-config/configtx/$channel.pb"
  runCLI "CORE_PEER_ADDRESS=peer1.$ORG.$DOMAIN:7051 peer channel join -b crypto-config/configtx/$channel.pb"
}

function updateAnchorPeers (){
    channel=${1:?Channel name must be specified}
    updateChannelConfig $ORG $channel ./templates/AnchorPeers.json
}


function installChaincode() {
    chaincodeName=${1:?Chaincode name must be specified}
    chaincodePath=${2:-$chaincodeName}
    lang=${3:-golang}
    chaincodeVersion=${4:-1.0}

    echo "Install chaincode $chaincodeName  $path $lang $version"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode install -n $chaincodeName -v $chaincodeVersion -p $chaincodePath -l $lang"
    runCLI "CORE_PEER_ADDRESS=peer1.$ORG.$DOMAIN:7051 peer chaincode install -n $chaincodeName -v $chaincodeVersion -p $chaincodePath -l $lang"
}


function instantiateChaincode() {
    channelName=${1:?Channel name must be specified}
    chaincodeName=${2:?Chaincode name must be specified}
    initArguments=${3:-[]}
    chaincodeVersion=${4:-1.0}
    path=${5}
    privateCollection=${6}


    arguments="{\"Args\":$initArguments}"
    echo "Instantiate chaincode $channelName $chaincodeName '$initArguments' $chaincodeVersion"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode instantiate -n $chaincodeName -v ${chaincodeVersion} -c '$arguments' -o orderer.$DOMAIN:7050 -C $channelName --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt --collections-config ${path}${privateCollection}.json"
# runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode instantiate -n $chaincodeName -v ${chaincodeVersion} -c '$arguments' -o orderer.$DOMAIN:7050 -C $channelName --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
}


function upgradeChaincode() {
    channelName=${1:?Channel name must be specified}
    chaincodeName=${2:?Chaincode name must be specified}
    initArguments=${3:-[]}
    chaincodeVersion=${4:-1.0}
    policy=${5}
    if [ -n "$policy" ]; then policy="-P \"$policy\""; fi

    arguments="{\"Args\":$initArguments}"
    echo "Upgrade chaincode $channelName $chaincodeName '$initArguments' $chaincodeVersion '$policy'"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode upgrade -n $chaincodeName -v $chaincodeVersion -c '$arguments' -o orderer.$DOMAIN:7050 -C $channelName "$policy" --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
}

function callChaincode() {
    channelName=${1:?Channel name must be specified}
    chaincodeName=${2:?Chaincode name must be specified}
    arguments=${3:-[]}
    arguments="{\"Args\":$arguments}"
    action=${4:-query}

    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode $action -n $chaincodeName -C $channelName -c '$arguments' --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
}

function queryChaincode() {
    callChaincode $@ query
}
function invokeChaincode() {
    callChaincode $@ invoke
}
