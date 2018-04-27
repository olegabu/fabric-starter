#!/usr/bin/env bash

starttime=$(date +%s)

# defaults; export these variables before executing this script
composeTemplatesFolder="docker-compose-templates"
artifactsTemplatesFolder="artifact-templates"
: ${FABRIC_STARTER_HOME:=$PWD}
: ${TEMPLATES_ARTIFACTS_FOLDER:=$FABRIC_STARTER_HOME/$artifactsTemplatesFolder}
: ${TEMPLATES_DOCKER_COMPOSE_FOLDER:=$FABRIC_STARTER_HOME/$composeTemplatesFolder}
: ${GENERATED_ARTIFACTS_FOLDER:=./artifacts}
: ${GENERATED_DOCKER_COMPOSE_FOLDER:=./dockercompose}

: ${DOMAIN:="example.com"}
: ${IP_ORDERER:="54.234.201.67"}
: ${ORG1:="a"}
: ${ORG2:="b"}
: ${ORG3:="c"}
: ${IP1:="54.86.191.160"}
: ${IP2:="54.243.0.168"}
: ${IP3:="54.211.142.174"}

echo "Use Fabric-Starter home: $FABRIC_STARTER_HOME"
echo "Use docker compose template folder: $TEMPLATES_DOCKER_COMPOSE_FOLDER"
echo "Use target artifact folder: $GENERATED_ARTIFACTS_FOLDER"
echo "Use target docker-compose folder: $GENERATED_DOCKER_COMPOSE_FOLDER"

[[ -d $GENERATED_ARTIFACTS_FOLDER ]] || mkdir $GENERATED_ARTIFACTS_FOLDER
[[ -d $GENERATED_DOCKER_COMPOSE_FOLDER ]] || mkdir $GENERATED_DOCKER_COMPOSE_FOLDER
cp -f "$TEMPLATES_DOCKER_COMPOSE_FOLDER/base.yaml" "$GENERATED_DOCKER_COMPOSE_FOLDER"
cp -f "$TEMPLATES_DOCKER_COMPOSE_FOLDER/base-intercept.yaml" "$GENERATED_DOCKER_COMPOSE_FOLDER"
if [[ -d ./$composeTemplatesFolder ]]; then cp -f "./$composeTemplatesFolder/base-intercept.yaml" "$GENERATED_DOCKER_COMPOSE_FOLDER"; fi


WGET_OPTS="--verbose -N"
CLI_TIMEOUT=10000
COMPOSE_TEMPLATE=$TEMPLATES_DOCKER_COMPOSE_FOLDER/docker-composetemplate.yaml
COMPOSE_FILE_DEV=$TEMPLATES_DOCKER_COMPOSE_FOLDER/docker-composedev.yaml

CHAINCODE_COMMON_NAME=reference
CHAINCODE_BILATERAL_NAME=relationship
CHAINCODE_COMMON_INIT='{"Args":["init","a","100","b","100"]}'
CHAINCODE_BILATERAL_INIT='{"Args":["init","a","100","b","100"]}'

DEFAULT_ORDERER_PORT=7050
DEFAULT_WWW_PORT=8080
DEFAULT_API_PORT=4000
DEFAULT_CA_PORT=7054
DEFAULT_PEER0_PORT=7051
DEFAULT_PEER0_EVENT_PORT=7053
DEFAULT_PEER1_PORT=7056
DEFAULT_PEER1_EVENT_PORT=7058

DEFAULT_PEER_EXTRA_HOSTS="extra_hosts:[newline]      - orderer.$DOMAIN:$IP_ORDERER"
DEFAULT_CLI_EXTRA_HOSTS="extra_hosts:[newline]      - orderer.$DOMAIN:$IP_ORDERER[newline]      - www.$DOMAIN:$IP_ORDERER[newline]      - www.$ORG1.$DOMAIN:$IP1[newline]      - www.$ORG2.$DOMAIN:$IP2[newline]      - www.$ORG3.$DOMAIN:$IP3"
DEFAULT_API_EXTRA_HOSTS1="extra_hosts:[newline]      - orderer.$DOMAIN:$IP_ORDERER[newline]      - peer0.$ORG2.$DOMAIN:$IP2[newline]      - peer0.$ORG3.$DOMAIN:$IP3"
DEFAULT_API_EXTRA_HOSTS2="extra_hosts:[newline]      - orderer.$DOMAIN:$IP_ORDERER[newline]      - peer0.$ORG1.$DOMAIN:$IP1[newline]      - peer0.$ORG3.$DOMAIN:$IP3"
DEFAULT_API_EXTRA_HOSTS3="extra_hosts:[newline]      - orderer.$DOMAIN:$IP_ORDERER[newline]      - peer0.$ORG1.$DOMAIN:$IP1[newline]      - peer0.$ORG2.$DOMAIN:$IP2"

GID=$(id -g)

function removeUnwantedContainers() {
  docker ps -a -q -f "name=dev-*"|xargs docker rm -f
}

# Delete any images that were generated as a part of this setup
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "No images available for deletion"
  else
    echo "Removing docker images: $DOCKER_IMAGE_IDS"
    docker rmi -f ${DOCKER_IMAGE_IDS}
  fi
}

function removeArtifacts() {
  echo "Removing generated and downloaded artifacts from: $GENERATED_DOCKER_COMPOSE_FOLDER, $GENERATED_ARTIFACTS_FOLDER"
  rm $GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-*.yaml
  rm -rf $GENERATED_ARTIFACTS_FOLDER/crypto-config
  rm -rf $GENERATED_ARTIFACTS_FOLDER/channel
  rm -rf $GENERATED_ARTIFACTS_FOLDER/*block*
  rm -rf www/artifacts && mkdir -p www/artifacts
  rm -rf $GENERATED_ARTIFACTS_FOLDER/cryptogen-*.yaml
  rm -rf $GENERATED_ARTIFACTS_FOLDER/fabric-ca-server-config-*.yaml
  rm -rf $GENERATED_ARTIFACTS_FOLDER/network-config.json
  rm -rf $GENERATED_ARTIFACTS_FOLDER/configtx.yaml
  rm -rf $GENERATED_ARTIFACTS_FOLDER/*Config.json
  rm -rf $GENERATED_ARTIFACTS_FOLDER/*.pb
  rm -rf $GENERATED_ARTIFACTS_FOLDER/updated_config.*
  rm -rf $GENERATED_ARTIFACTS_FOLDER/update_in_envelope.*
  rm -rf $GENERATED_ARTIFACTS_FOLDER/update.*
  rm -rf $GENERATED_ARTIFACTS_FOLDER/config.*
  rm -rf $GENERATED_ARTIFACTS_FOLDER/hosts
  rm -rf $GENERATED_ARTIFACTS_FOLDER/crypto-temp
}

function removeDockersFromAllCompose() {
    for o in ${DOMAIN} ${ORG1} ${ORG2} ${ORG3}
    do
      removeDockersFromCompose ${o}
    done
}

function removeDockersFromCompose() {
  o=$1
  f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$o.yaml"

  if [ -f ${f} ]; then
      info "stopping docker instances from $f"
      docker-compose -f ${f} down
      docker-compose -f ${f} kill
      docker-compose -f ${f} rm -f
  fi;
}

function removeDockersWithDomain() {
  search="$DOMAIN"
  docker_ids=$(docker ps -a | grep ${search} | awk '{print $1}')
  if [ -z "$docker_ids" -o "$docker_ids" == " " ]; then
    echo "No docker instances available for deletion with $search"
  else
    echo "Removing docker instances found with $search: $docker_ids"
    docker rm -f ${docker_ids}
  fi
}

function removeDockersWithOrg() {
  search="$1"
  docker_ids=$(docker ps -a | grep ${search} | awk '{print $1}')
  if [ -z "$docker_ids" -o "$docker_ids" == " " ]; then
    echo "No docker instances available for deletion with $search"
  else
    echo "Removing docker instances found with $search: $docker_ids"
    docker rm -f ${docker_ids}
  fi
}

function generateOrdererDockerCompose() {
    mainOrg=$1
    echo "Creating orderer docker compose yaml file with $DOMAIN, $ORG1, $ORG2, $ORG3, $DEFAULT_ORDERER_PORT, $DEFAULT_WWW_PORT"

    compose_template=$TEMPLATES_DOCKER_COMPOSE_FOLDER/docker-composetemplate-orderer.yaml
    if [ -n "$mainOrg" ]; then
        compose_template=$TEMPLATES_DOCKER_COMPOSE_FOLDER/docker-composetemplate-orderer-main-org.yaml #todo: made one template
    fi

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$DOMAIN.yaml"

    cli_extra_hosts=${DEFAULT_CLI_EXTRA_HOSTS}

    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/MAIN_ORG/$mainOrg/g" -e "s/CLI_EXTRA_HOSTS/$cli_extra_hosts/g" -e "s/ORDERER_PORT/$DEFAULT_ORDERER_PORT/g" -e "s/WWW_PORT/$DEFAULT_WWW_PORT/g" -e "s/ORG1/$ORG1/g" -e "s/ORG2/$ORG2/g" -e "s/ORG3/$ORG3/g" ${compose_template} | awk '{gsub(/\[newline\]/, "\n")}1' > ${f}
}

function generateNetworkConfig() {
  orgs=${@}

  echo "Generating network-config.json for $orgs, ${orgs[0]}"

  networkConfigTemplate=$TEMPLATES_ARTIFACTS_FOLDER/network-config-template.json
  if [ -f ./$artifactsTemplatesFolder/network-config-template.json ]; then
    networkConfigTemplate=./$artifactsTemplatesFolder/network-config-template.json
  fi

  # replace for orderer in network-config.json
  # TODO: replace ORG1.
  out=`sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/${orgs[0]}/g" -e "s/DEV_DEPLOYMENT/$DEV_DEPLOYMENT/g" -e "s/^\s*\/\/.*$//g" $networkConfigTemplate`
  placeholder=",}}"

#TEMPLATES_ARTIFACTS_FOLDER/network-config-template.json`

  for org in ${orgs}
    do
      snippet=`sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$org/g" $TEMPLATES_ARTIFACTS_FOLDER/network-config-orgsnippet.json`
#      echo ${snippet}
      out="${out//$placeholder/,$snippet}"
    done

  out="${out//$placeholder/\}\}}"

  echo ${out} > $GENERATED_ARTIFACTS_FOLDER/network-config.json
}

function addOrgToNetworkConfig() {
  org=$1

  echo "Adding $org to network-config.json"

  out=`cat $GENERATED_ARTIFACTS_FOLDER/network-config.json`
  placeholder="}}}"

  snippet=`sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$org/g" $TEMPLATES_ARTIFACTS_FOLDER/network-config-orgsnippet.json`
#  echo ${snippet}
  out="${out//$placeholder/\},$snippet}"

  out="${out//,\}\}/\}\}}"

  echo ${out} > $GENERATED_ARTIFACTS_FOLDER/network-config.json
}

#
#function executeBashCmdInCli () {
#  file=$GENERATED_DOCKER_COMPOSE_FOLDER/$1
#  container=$2
#  cmd=$3
#
#  echo "using: $file"
#  docker-compose --file ${file} run --rm "$container" bash -c "$cmd"
#
#}

function generateOrdererArtifacts() {
    org=$1

    echo "Creating orderer yaml files with $DOMAIN, $ORG1, $ORG2, $ORG3, $DEFAULT_ORDERER_PORT, $DEFAULT_WWW_PORT"

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$DOMAIN.yaml"

    mkdir -p "$GENERATED_ARTIFACTS_FOLDER/channel"


    if [[ -n "$org" ]]; then
        generateNetworkConfig ${org}
        sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/$org/g" "$TEMPLATES_ARTIFACTS_FOLDER/configtxtemplate-oneOrg-orderer.yaml" > $GENERATED_ARTIFACTS_FOLDER/configtx.yaml
        createChannels=("common")
    else
        generateNetworkConfig ${ORG1} ${ORG2} ${ORG3}
        # replace in configtx
        sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/$ORG1/g" -e "s/ORG2/$ORG2/g" -e "s/ORG3/$ORG3/g" $TEMPLATES_ARTIFACTS_FOLDER/configtxtemplate.yaml > $GENERATED_ARTIFACTS_FOLDER/configtx.yaml
        createChannels=("common" "$ORG1-$ORG2" "$ORG1-$ORG3" "$ORG2-$ORG3")
    fi


    for channel_name in ${createChannels[@]}
    do
        echo "Generating channel config transaction for $channel_name"
        docker-compose --file ${f} run --rm -e FABRIC_CFG_PATH=/etc/hyperledger/artifacts "cli.$DOMAIN" configtxgen -profile "$channel_name" -outputCreateChannelTx "./channel/$channel_name.tx" -channelID "$channel_name"
    done

    # replace in cryptogen
    sed -e "s/DOMAIN/$DOMAIN/g" $TEMPLATES_ARTIFACTS_FOLDER/cryptogentemplate-orderer.yaml > "$GENERATED_ARTIFACTS_FOLDER/cryptogen-$DOMAIN.yaml"

    echo "Generating crypto material with cryptogen"

    echo "docker-compose --file ${f} run --rm \"cli.$DOMAIN\" bash -c \"sleep 2 && cryptogen generate --output=crypto --config=cryptogen-$DOMAIN.yaml\""
    docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "sleep 2 && cryptogen generate  --output=crypto-temp --config=cryptogen-$DOMAIN.yaml &&     cp -r -f crypto-temp/. crypto-config"

    sleep 1




    echo "Generating orderer genesis block with configtxgen"
    docker-compose --file ${f} run --rm -e FABRIC_CFG_PATH=/etc/hyperledger/artifacts "cli.$DOMAIN" configtxgen -profile OrdererGenesis -outputBlock ./channel/genesis.block

    echo "Changing artifacts file ownership"
    docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "chown -R $UID:$GID ."
}

function generatePeerArtifacts() {
    org=$1

    [[ ${#} == 0 ]] && echo "missing required argument -o ORG" && exit 1

    if [ ${#} == 1 ]; then
      # if no port args are passed assume generating for multi host deployment
      peer_extra_hosts=${DEFAULT_PEER_EXTRA_HOSTS}
      cli_extra_hosts=${DEFAULT_CLI_EXTRA_HOSTS}
      if [ ${org} == ${ORG1} ]; then
        api_extra_hosts=${DEFAULT_API_EXTRA_HOSTS1}
      elif [ ${org} == ${ORG2} ]; then
        api_extra_hosts=${DEFAULT_API_EXTRA_HOSTS2}
      elif [ ${org} == ${ORG3} ]; then
        api_extra_hosts=${DEFAULT_API_EXTRA_HOSTS3}
      fi
    fi

    api_port=$2
    www_port=$3
    ca_port=$4
    peer0_port=$5
    peer0_event_port=$6
    peer1_port=$7
    peer1_event_port=$8

    : ${api_port:=${DEFAULT_API_PORT}}
    : ${www_port:=${DEFAULT_WWW_PORT}}
    : ${ca_port:=${DEFAULT_CA_PORT}}
    : ${peer0_port:=${DEFAULT_PEER0_PORT}}
    : ${peer0_event_port:=${DEFAULT_PEER0_EVENT_PORT}}
    : ${peer1_port:=${DEFAULT_PEER1_PORT}}
    : ${peer1_event_port:=${DEFAULT_PEER1_EVENT_PORT}}

    echo "Creating peer yaml files with $DOMAIN, $org, $api_port, $www_port, $ca_port, $peer0_port, $peer0_event_port, $peer1_port, $peer1_event_port"

    compose_template=$TEMPLATES_DOCKER_COMPOSE_FOLDER/docker-composetemplate-peer.yaml
    if [ -n "$MAIN_ORG" ]; then
        compose_template=$TEMPLATES_DOCKER_COMPOSE_FOLDER/docker-composetemplate-orderer-main-org.yaml
    fi

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$org.yaml"

    # cryptogen yaml
    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$org/g" $TEMPLATES_ARTIFACTS_FOLDER/cryptogentemplate-peer.yaml > $GENERATED_ARTIFACTS_FOLDER/"cryptogen-$org.yaml"

    # docker-compose yaml
    sed -e "s/PEER_EXTRA_HOSTS/$peer_extra_hosts/g" -e "s/CLI_EXTRA_HOSTS/$cli_extra_hosts/g" -e "s/API_EXTRA_HOSTS/$api_extra_hosts/g" -e "s/DOMAIN/$DOMAIN/g" -e "s/\([^ ]\)ORG/\1$org/g" -e "s/API_PORT/$api_port/g" -e "s/WWW_PORT/$www_port/g" -e "s/CA_PORT/$ca_port/g" -e "s/PEER0_PORT/$peer0_port/g" -e "s/PEER0_EVENT_PORT/$peer0_event_port/g" -e "s/PEER1_PORT/$peer1_port/g" -e "s/PEER1_EVENT_PORT/$peer1_event_port/g" ${compose_template} | awk '{gsub(/\[newline\]/, "\n")}1' > ${f}

    # fabric-ca-server-config yaml
    sed -e "s/ORG/$org/g" $TEMPLATES_ARTIFACTS_FOLDER/fabric-ca-server-configtemplate.yaml > $GENERATED_ARTIFACTS_FOLDER/"fabric-ca-server-config-$org.yaml"

    mkdir -p $GENERATED_ARTIFACTS_FOLDER/hosts/${org} # TODO: move to outer level
    cp $TEMPLATES_ARTIFACTS_FOLDER/default_hosts $GENERATED_ARTIFACTS_FOLDER/hosts/${org}/api_hosts
    cp $TEMPLATES_ARTIFACTS_FOLDER/default_hosts $GENERATED_ARTIFACTS_FOLDER/hosts/${org}/cli_hosts

    echo "Generating crypto material with cryptogen"

    echo "docker-compose --file ${f} run --rm \"cliNoCryptoVolume.$org.$DOMAIN\" bash -c \"cryptogen generate --config=cryptogen-$org.yaml\""
    docker-compose --file ${f} run --rm "cliNoCryptoVolume.$org.$DOMAIN" bash -c "sleep 2 && cryptogen generate --config=cryptogen-$org.yaml"

    echo "Changing artifacts ownership"
    docker-compose --file ${f} run --rm "cliNoCryptoVolume.$org.$DOMAIN" bash -c "chown -R $UID:$GID ."

    echo "Adding generated CA private keys filenames to $f"
    ca_private_key=$(basename `ls -t $GENERATED_ARTIFACTS_FOLDER/crypto-config/peerOrganizations/"$org.$DOMAIN"/ca/*_sk`)
    [[ -z  ${ca_private_key}  ]] && echo "empty CA private key" && exit 1
    sed -i -e "s/CA_PRIVATE_KEY/${ca_private_key}/g" ${f}

    # replace in configtx
    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$org/g" $TEMPLATES_ARTIFACTS_FOLDER/configtx-orgtemplate.yaml > $GENERATED_ARTIFACTS_FOLDER/configtx.yaml

    echo "Generating ${org}Config.json"
    echo "docker-compose --file ${f} run --rm \"cliNoCryptoVolume.$org.$DOMAIN\" bash -c \"FABRIC_CFG_PATH=./ configtxgen  -printOrg ${org}MSP > ${org}Config.json\""
    docker-compose --file ${f} run --rm "cliNoCryptoVolume.$org.$DOMAIN" bash -c "FABRIC_CFG_PATH=./ configtxgen  -printOrg ${org}MSP > ${org}Config.json"
}

function addOrgToApiHosts() {
  thisOrg=$1
  remoteOrg=$2
  ip=$3
  # check duplication
  echo "$ip peer0.$remoteOrg.$DOMAIN peer1.$remoteOrg.$DOMAIN" >> $GENERATED_ARTIFACTS_FOLDER/hosts/${thisOrg}/api_hosts
}

function addOrgToCliHosts() {
  thisOrg=$1
  serverName=$2
  ip=$3
  # check duplication
  echo "$ip $serverName.$DOMAIN" >> $GENERATED_ARTIFACTS_FOLDER/hosts/${thisOrg}/cli_hosts
}

function copyFilesToWWW() {
  dir=$1
  targetFileOrDir=$2
  comment=$3
  org=$4

  echo "Copying $comment files from $dir to be served by www.$org.$DOMAIN"
  mkdir -p "www/${dir}"
  echo "cp -r ${dir}/${targetFileOrDir} www/${dir}"
  cp -r ${dir}/${targetFileOrDir} www/${dir}
}

function servePeerArtifacts() {
    org=$1

    copyFilesToWWW "$GENERATED_ARTIFACTS_FOLDER/crypto-config/peerOrganizations/$org.$DOMAIN/peers/peer0.$org.$DOMAIN/tls" "ca.crt" "generated TLS cert" $org
    copyFilesToWWW "$GENERATED_ARTIFACTS_FOLDER/crypto-config/peerOrganizations/$org.$DOMAIN" "msp" "generated TLS cert" $org
    copyFilesToWWW "$GENERATED_ARTIFACTS_FOLDER" "${org}Config.json" "generated ${org}Config.json" $org

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$org.yaml"
    docker-compose --file ${f} up -d "www.$org.$DOMAIN"
}


function serveOrdererArtifacts() {

    copyFilesToWWW "$GENERATED_ARTIFACTS_FOLDER/crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/tls" "ca.crt" "generated orderer TLS cert"
    copyFilesToWWW "$GENERATED_ARTIFACTS_FOLDER/crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/msp/tlscacerts" "tlsca.${DOMAIN}-cert.pem" "generated orderer MSP cert"
    copyFilesToWWW "$GENERATED_ARTIFACTS_FOLDER/channel" '*.tx' "channel transaction config"
    copyNetworkConfigToWWW

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$DOMAIN.yaml"
    docker-compose --file ${f} up -d "www.$DOMAIN"
}

function copyNetworkConfigToWWW() {
    copyFilesToWWW "$GENERATED_ARTIFACTS_FOLDER" "network-config.json" "generated network config"
}

function generateChannelConfig() {

    mainOrg=$1
    channel_name=$2

    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/$mainOrg/g" -e "s/CHANNEL_NAME/$channel_name/g"  $TEMPLATES_ARTIFACTS_FOLDER/configtxtemplate-oneOrg-orderer.yaml > $GENERATED_ARTIFACTS_FOLDER/configtx.yaml

    i=2
    for org in "${@:3}"
    do
        echo "sed -e \"s/ORG${i}/$org/g\" $GENERATED_ARTIFACTS_FOLDER/configtx.yaml > $GENERATED_ARTIFACTS_FOLDER/configtx.yaml.tmp && mv $GENERATED_ARTIFACTS_FOLDER/configtx.yaml.tmp $GENERATED_ARTIFACTS_FOLDER/configtx.yaml"
        sed -e "s/ORG${i}/$org/g" $GENERATED_ARTIFACTS_FOLDER/configtx.yaml > "$GENERATED_ARTIFACTS_FOLDER/configtx.yaml.tmp" && mv "$GENERATED_ARTIFACTS_FOLDER/configtx.yaml.tmp" "$GENERATED_ARTIFACTS_FOLDER/configtx.yaml"
        i=$((i+1))
    done

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$DOMAIN.yaml"
    docker-compose --file ${f} run --rm -e FABRIC_CFG_PATH=/etc/hyperledger/artifacts "cli.$DOMAIN" configtxgen -profile "$channel_name" -outputCreateChannelTx "./channel/$channel_name.tx" -channelID "$channel_name"
}

function createChannel () {
    org=$1
    channel_name=$2
    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-${org}.yaml"

    info "creating channel $channel_name by $org using $f"

    echo "docker-compose --file ${f} run --rm \"cli.$org.$DOMAIN\" bash -c \"peer channel create -o orderer.$DOMAIN:7050 -c $channel_name -f /etc/hyperledger/artifacts/channel/$channel_name.tx --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt\""
    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "peer channel create -o orderer.$DOMAIN:7050 -c $channel_name -f /etc/hyperledger/artifacts/channel/$channel_name.tx --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"

    echo "changing ownership of channel block files"
    docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "chown -R $UID:$GID ."

    d="$GENERATED_ARTIFACTS_FOLDER"
    echo "copying channel block file from ${d} to be served by www.$org.$DOMAIN"
    cp "${d}/$channel_name.block" "www/${d}"
}

function joinChannel() {
    org=$1
    channel_name=$2
    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-${org}.yaml"

    info "joining channel $channel_name by all peers of $org using $f"

    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer channel join -b $channel_name.block"
    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "CORE_PEER_ADDRESS=peer1.$org.$DOMAIN:7051 peer channel join -b $channel_name.block"
}

function instantiateChaincode () {
    org=$1
    channel_names=($2)
    n=$3
    i=$4
    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-${org}.yaml"

    for channel_name in ${channel_names[@]}; do
        info "instantiating chaincode $n on $channel_name by $org using $f with $i"

        c="CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode instantiate -n $n -v 1.0 -c '$i' -o orderer.$DOMAIN:7050 -C $channel_name --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
        d="cli.$org.$DOMAIN"

        echo "instantiating with $d by $c"
        docker-compose --file ${f} run --rm ${d} bash -c "${c}"
    done
}

function warmUpChaincode () {
    org=$1
    channel_names=($2)
    n=$3
    initArgs=$4
    if [ -z "$initArgs" ]; then
      initArgs='{\"Args\":[\"query\, "$org"]}'
    fi
    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-${org}.yaml"

    for channel_name in ${channel_names[@]}; do
        info "warming up chaincode $n on $channel_name on all peers of $org with query using $f"

        c="CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode query -n $n -v 1.0 -c '$initArgs' -C $channel_name \
        && CORE_PEER_ADDRESS=peer1.$org.$DOMAIN:7051 peer chaincode query -n $n -v 1.0 -c '$initArgs' -C $channel_name"
        d="cli.$org.$DOMAIN"

        echo "warming up with $d by $c"
        docker-compose --file ${f} run --rm ${d} bash -c "${c}"
    done
}

function installChaincode() {
    org=$1
    n=$2
    v=$3
    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-${org}.yaml"
    # chaincode path is the same as chaincode name by convention: code of chaincode instruction lives in ./chaincode/go/instruction mapped to docker path /opt/gopath/src/instruction
    p=${n}
    #p=/opt/chaincode/node
    l=golang
    #l=node

    info "installing chaincode $n to peers of $org from ./chaincode/go/$p $v using $f"

    echo "docker-compose --file ${f} run --rm \"cli.$org.$DOMAIN\" bash -c \"CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode install -n $n -v $v -p $p -l $l "
    echo " && CORE_PEER_ADDRESS=peer1.$org.$DOMAIN:7051 peer chaincode install -n $n -v $v -p $p -l $l\""

    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode install -n $n -v $v -p $p -l $l \
    && CORE_PEER_ADDRESS=peer1.$org.$DOMAIN:7051 peer chaincode install -n $n -v $v -p $p -l $l"
}

function upgradeChaincode() {
    org=$1
    n=$2
    v=$3
    i=$4
    channel_name=$5
    policy=$6
    if [ -n "$policy" ]; then policy="-P \"$policy\""; fi

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-${org}.yaml"
    c="CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode upgrade -n $n -v $v -c '$i' -o orderer.$DOMAIN:7050 -C $channel_name "$policy" --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
    d="cli.$org.$DOMAIN"

    info "upgrading chaincode $n to $v using $d with $c and andorsement policy $policy"
    docker-compose --file ${f} run --rm ${d} bash -c "$c"
}


function dockerComposeUp () {
  compose_file="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$1.yaml"

  info "starting docker instances from $compose_file"

  TIMEOUT=${CLI_TIMEOUT} docker-compose -f ${compose_file} up -d 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start network"
    logs ${1}
    exit 1
  fi
}

function dockerComposeDown () {
  compose_file="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$1.yaml"

  if [ -f ${compose_file} ]; then
      info "stopping docker instances from $compose_file"
      docker-compose -f ${compose_file} down
  fi;
}

function dockerContainerRestart () {
  org=$1
  service=$2

  compose_file="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$org.yaml"

  echo "Restart container: docker-compose -f ${compose_file} restart $service.$org.$DOMAIN"
  docker-compose -f ${compose_file} restart $service.$org.$DOMAIN
}

function installAll() {
  org=$1

  sleep 2

  for chaincode_name in ${CHAINCODE_COMMON_NAME} ${CHAINCODE_BILATERAL_NAME}
  do
    installChaincode ${org} ${chaincode_name} "1.0"
  done
}

function joinWarmUp() {
  org=$1
  channel_name=$2
  chaincode_name=$3

  joinChannel ${org} ${channel_name}
#  sleep 2
#  warmUpChaincode ${org} ${channel_name} ${chaincode_name}
}

function createJoinInstantiateWarmUp() {
  org=${1}
  channel_name=${2}
  chaincode_name=${3}
  chaincode_init=${4}

  createChannel ${org} ${channel_name}
  joinChannel ${org} ${channel_name}
  instantiateChaincode ${org} ${channel_name} ${chaincode_name} ${chaincode_init}
#  sleep 2
#  warmUpChaincode ${org} ${channel_name} ${chaincode_name}
}

function makeCertDirs() {
  mkdir -p "$GENERATED_ARTIFACTS_FOLDER/crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/tls"

#  for org in ${ORG1} ${ORG2} ${ORG3}
   for certDirsOrg in "$@"
    do
        d="$GENERATED_ARTIFACTS_FOLDER/crypto-config/peerOrganizations/$certDirsOrg.$DOMAIN/peers/peer0.$certDirsOrg.$DOMAIN/tls"
        echo "mkdir -p ${d}"
        mkdir -p ${d}
    done
}

function downloadMemberMSP() {

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$DOMAIN.yaml"

    info "downloading member MSP files using $f"

   #${ORG1} ${ORG2} ${ORG3}

    c="for ORG in ${@}; do wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/admincerts http://www.\$ORG.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/admincerts/Admin@\$ORG.$DOMAIN-cert.pem && wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/cacerts http://www.\$ORG.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/cacerts/ca.\$ORG.$DOMAIN-cert.pem && wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/tlscacerts http://www.\$ORG.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/tlscacerts/tlsca.\$ORG.$DOMAIN-cert.pem; done"
    echo ${c}
#    executeBashCmdInCli "docker-compose-$DOMAIN.yaml" "cli.$DOMAIN" "${c} && chown -R $UID:$GID ."
    docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."

#    #workaround until orderer-based network is implemented
#    if [ -n $THIS_ORG ]; then
#      f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$THIS_ORG.yaml"
#      docker-compose --file ${f} run --rm "cli.$THIS_ORG.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."
#    fi
}

function downloadNetworkConfig() {
    org=$1
    [[ -n "$2" ]] && mainOrgDomain="$2." || mainOrgDomain=""

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$org.yaml"

    info "downloading network config file using $f"

    c="wget ${WGET_OPTS} http://www.${mainOrgDomain}$DOMAIN:$DEFAULT_WWW_PORT/network-config.json && chown -R $UID:$GID ."
    echo ${c}
    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c}"
}

function downloadChannelTxFiles() {
    org=$1
    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$org.yaml"

    info "downloading all channel config transaction files using $f"
    for channel_name in ${@}
    do
      c="wget ${WGET_OPTS} --directory-prefix channel http://www.$DOMAIN:$DEFAULT_WWW_PORT/channel/$channel_name.tx && chown -R $UID:$GID ."
      echo ${c}
      docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c}"
    done
}

function downloadChannelBlockFile() {
    org=$1
    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$org.yaml"

    leader=$2
    channel_name=$3

    info "downloading channel block file of created $channel_name from $DOMAIN and $leader using $f"

    c="wget ${WGET_OPTS} http://www.$DOMAIN:$DEFAULT_WWW_PORT/$channel_name.block && chown -R $UID:$GID ."
    echo ${c}
    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c}"

    #workaround until orderer-based network is implemented
    c="wget ${WGET_OPTS} http://www.$leader.$DOMAIN:$DEFAULT_WWW_PORT/$channel_name.block && chown -R $UID:$GID ."
    echo ${c}
    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c}"
}

function downloadArtifactsMember() {
  makeCertDirs ${ORG1} ${ORG2} ${ORG3}

  org=$1
  mainOrg=$2
  remoteOrg=$3
  f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$org.yaml"

  downloadChannelTxFiles ${@}
  downloadNetworkConfig ${org} ${mainOrg}

  info "downloading orderer cert file using $f"

  c="wget ${WGET_OPTS} --directory-prefix crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/tls http://www.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/tls/ca.crt"
  echo ${c}
  docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."

  #TODO download not from all members but from the orderer
  info "downloading member cert files using $f"

  c="for ORG in ${ORG1} ${ORG2} ${ORG3}; do wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\${ORG}.$DOMAIN/peers/peer0.\${ORG}.$DOMAIN/tls http://www.\${ORG}.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\${ORG}.$DOMAIN/peers/peer0.\${ORG}.$DOMAIN/tls/ca.crt; done"
  echo ${c}
  docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."

  if [ -n "$remoteOrg" ]; then
    makeCertDirs $remoteOrg
    c="wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/${remoteOrg}.$DOMAIN/peers/peer0.${remoteOrg}.$DOMAIN/tls http://www.${remoteOrg}.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/${remoteOrg}.$DOMAIN/peers/peer0.${remoteOrg}.$DOMAIN/tls/ca.crt"
    echo ${c}

    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."
  fi
}

function downloadArtifactsOrderer() {
#  for org in ${ORG1} ${ORG2} ${ORG3}
#    do
#      rm -rf "artifacts/crypto-config/peerOrganizations/$org.$DOMAIN"
#    done

  mainOrg=$1
  if [ -z "$mainOrg" ]; then
      makeCertDirs ${ORG1} ${ORG2} ${ORG3}
      downloadMemberMSP ${ORG1} ${ORG2} ${ORG3}

      info "downloading member cert files using $f"

      c="for ORG in ${ORG1} ${ORG2} ${ORG3}; do wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\${ORG}.$DOMAIN/peers/peer0.\${ORG}.$DOMAIN/tls http://www.\${ORG}.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\${ORG}.$DOMAIN/peers/peer0.\${ORG}.$DOMAIN/tls/ca.crt; done"
      echo ${c}
    #  executeBashCmdInCli "docker-compose-$DOMAIN.yaml" "cli.$DOMAIN" "${c} && chown -R $UID:$GID ."
      f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$DOMAIN.yaml"
      docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."
  fi
}

#############################
#
# Install toolset on cli required to perform signing and other operations - jq, configtxlator, etc.
#
# Example usage: installCliToolset "org-name"
#
#############################
function startConfigTxlator (){

  org=$1
  stop=$2

#  bin/configtxlator start &
#  sleep 2


  d="cli.$org.$DOMAIN"
  c="sudo pkill -9 configtxlator "

  docker exec -d ${d} bash -c "$c"
  sleep 2

  c="configtxlator start & "
  info "$org is starting configtxlator on $d by $c"
  [[ -z "$stop" ]] && docker exec -d ${d} bash -c "$c"

  echo "waiting 3s for configtxlator to start..."
  sleep 3
}

function addOrg() {
  org=$1
  channel=$2

  info "adding org $org to channel $channel"

  rm -rf "$GENERATED_ARTIFACTS_FOLDER/crypto-config/peerOrganizations/$org.$DOMAIN"

  removeDockersWithOrg ${org}

  rm -f $GENERATED_ARTIFACTS_FOLDER/newOrgMSP.json $GENERATED_ARTIFACTS_FOLDER/config.* $GENERATED_ARTIFACTS_FOLDER/update.* $GENERATED_ARTIFACTS_FOLDER/updated_config.* $GENERATED_ARTIFACTS_FOLDER/update_in_envelope.*

  # ex. generatePeerArtifacts foo 4005 8086 1254 1251 1253 1256 1258
  generatePeerArtifacts ${org} ${API_PORT} ${WWW_PORT} ${CA_PORT} ${PEER0_PORT} ${PEER0_EVENT_PORT} ${PEER1_PORT} ${PEER1_EVENT_PORT}

  dockerComposeUp ${org}

  addOrgToNetworkConfig ${org}

  configtxDir="$GENERATED_ARTIFACTS_FOLDER/"

  echo "generating configtx.yaml for $org into $configtxDir"
  mkdir -p ${configtxDir}
  sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$org/g" $TEMPLATES_ARTIFACTS_FOLDER/configtx-orgtemplate.yaml > "$configtxDir/configtx.yaml"

  d="cli.$org.$DOMAIN"
  c="FABRIC_CFG_PATH=../$configtxDir configtxgen -printOrg ${org}MSP > newOrgMSP.json"

  info "$org is generating newOrgMSP.json with $d by $c"
  docker exec ${d} bash -c "$c"

  startConfigTxlator ${ORG1}

  d="cli.$ORG1.$DOMAIN"
  c="peer channel fetch config config_block.pb -o orderer.$DOMAIN:7050 -c $channel --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt \
  && curl -X POST --data-binary @config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block | jq . > config_block.json \
  && jq .data.data[0].payload.data.config config_block.json > config.json \
  && jq -s '.[0] * {\"channel_group\":{\"groups\":{\"Application\":{\"groups\": {\"${org}MSP\":.[1]}}}}}' config.json newOrgMSP.json >& updated_config.json \
  && curl -X POST --data-binary @config.json http://127.0.0.1:7059/protolator/encode/common.Config > config.pb \
  && curl -X POST --data-binary @updated_config.json http://127.0.0.1:7059/protolator/encode/common.Config > updated_config.pb \
  && curl -X POST -F channel=$channel -F 'original=@config.pb' -F 'updated=@updated_config.pb' http://127.0.0.1:7059/configtxlator/compute/update-from-configs > update.pb \
  && curl -X POST --data-binary @update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate | jq . > update.json \
  && echo '{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"$channel\",\"type\":2}},\"data\":{\"config_update\":'\`cat update.json\`'}}}' | jq . > update_in_envelope.json \
  && curl -X POST --data-binary @update_in_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > update_in_envelope.pb"

  info "$ORG1 is generating config tx file update_in_envelope.pb with $d by $c"
  docker exec ${d} bash -c "$c"

  ! [[ -s $GENERATED_ARTIFACTS_FOLDER/config_block.json ]] && echo "$GENERATED_ARTIFACTS_FOLDER/config_block.json is empty. Is configtxlator running?" && exit 1

  for o in ${ORG1} ${ORG2} ${ORG3} ${ORG4} ${ORG5}
    do
      d="cli.$o.$DOMAIN"
      c="peer channel signconfigtx -f update_in_envelope.pb"

      info "$o is signing update_in_envelope.pb with $d by $c"
      docker exec ${d} bash -c "$c"
    done

  d="cli.$ORG1.$DOMAIN"
  c="peer channel update -f update_in_envelope.pb -c $channel -o orderer.$DOMAIN:7050 --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"

  info "$ORG1 is sending channel update update_in_envelope.pb with $d by $c"
  docker exec ${d} bash -c "$c"

  installAll ${org}

  joinChannel ${org} ${channel}

  info "$ORG1 is upgrading chaincode $CHAINCODE_COMMON_NAME on $channel to include org $org in its endorsement policy"

  v="2.0"
  policy="OR ('${ORG1}MSP.member','${ORG2}MSP.member','${ORG3}MSP.member','${org}MSP.member')"

  for o in ${ORG1} ${ORG2} ${ORG3} ${org}
    do
      installChaincode ${o} ${CHAINCODE_COMMON_NAME} ${v}
    done

  upgradeChaincode ${ORG1} ${CHAINCODE_COMMON_NAME} ${v} ${CHAINCODE_COMMON_INIT} ${channel} \""${policy}"\"
}

##################################
#
# expects org name, ip address and common channels list to register organization in respectively as arguments.
#
# for each provided channel, calls for a specific registerNewOrgInChannel function, which registers the channel in
# the specified channel, one by one.
#
# after that, creates new channels with each existing organization in organizations list.
#
##################################
function registerNewOrg() {
  new_org=$1
  mainOrg=$2
  ip=$3
  channels=($4)

  f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-${mainOrg}.yaml"
  d="cli.$mainOrg.$DOMAIN"

  info " >> accepted the following channels list to register org ${new_org} in: ${@:4}; registering in channels one by one"

  for c in ${@:4} #"${channels[@]}"
    do
      # downloading newOrgMSP.json config
#      info " >> first downloading new org configuration json file from ip $ip"

      command="wget ${WGET_OPTS} http://$ip:$DEFAULT_WWW_PORT/${new_org}Config.json"
      echo ${c}
      docker-compose --file ${f} run --rm "${d}" bash -c "${command} && chown -R $UID:$GID ."

      registerNewOrgInChannel $mainOrg ${new_org} ${c}
    done

  info " >> new org ${new_org} has been registered in passed channels !"
}

#################################
#
# given the new config json file,
#
# Example usage:
# generateConfigUpdateEnvelop $ORG1 common "jq -s '.[0] * {\"channel_group\":{\"groups\":{\"Application\":{\"mod_policy\": \"${policyName}\", \"policies\":.[1]}}}}' config.json new_policy.json"
#
#################################
function updateChannelConfig() {

  org=$1
  channel=$2
  configReplacementScript=$3

  info " >> configReplacementScript: $configReplacementScript ..."
#  info " >> preparing update_in_envelope.pb envelop..."

#  && echo 'wc for artifacts/config_block.json: $(wc -c < artifacts/config_block.json)' \
#  && echo 'wc for artifacts/config.json: $(wc -c < artifacts/config.json)' \
#&& echo 'wc for artifacts/updated_config.json: $(wc -c < artifacts/updated_config.json)' \
#  && echo 'cat for artifacts/updated_config.json: $(cat artifacts/updated_config.json)' \
#  && echo 'wc for artifacts/update.json: $(wc -c < artifacts/update.json)' \
#  && echo 'wc for artifacts/update_in_envelope.json: $(wc -c < artifacts/update_in_envelope.json)' \
  cd $GENERATED_ARTIFACTS_FOLDER && rm -r -f config_block.pb config_block.json config.json config.pb updated_config.json updated_config.pb update.json update.pb update_in_envelope.json update_in_envelope.pb 2>&1

  command="peer channel fetch config config_block.pb -o orderer.$DOMAIN:7050 -c $channel --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
#  info " fetchig config_block for $channel with $d by $command"
  d="cli.$org.$DOMAIN"
  docker exec ${d} bash -c "$command"

  # now update the channel with the config delta envelop


  cliContainerIP=`docker inspect ${d} | jq .[0].NetworkSettings.Networks.dockercompose_default.IPAddress` #"http://127.0.0.1:7059"
  cliContainerIP="${cliContainerIP%\"}"
  cliContainerIP="${cliContainerIP#\"}"
  configtxlatorServer="http://${cliContainerIP}:7059"


  startConfigTxlator ${org}

  command="curl -X POST --data-binary @config_block.pb ${configtxlatorServer}/protolator/decode/common.Block | jq . > config_block.json \
  && jq .data.data[0].payload.data.config config_block.json > config.json"

  echo $command
  eval $command
  eval "jq -s ${configReplacementScript}" > updated_config.json

  command="curl -X POST --data-binary @config.json ${configtxlatorServer}/protolator/encode/common.Config > config.pb \
  && curl -X POST --data-binary @updated_config.json ${configtxlatorServer}/protolator/encode/common.Config > updated_config.pb \
  && curl -X POST -F channel=$channel -F 'original=@config.pb' -F 'updated=@updated_config.pb' ${configtxlatorServer}/configtxlator/compute/update-from-configs > update.pb \
  && curl -X POST --data-binary @update.pb ${configtxlatorServer}/protolator/decode/common.ConfigUpdate | jq . > update.json \
  && echo '{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"$channel\",\"type\":2}},\"data\":{\"config_update\":'\`cat update.json\`'}}}' | jq . > update_in_envelope.json \
  && curl -X POST --data-binary @update_in_envelope.json ${configtxlatorServer}/protolator/encode/common.Envelope > update_in_envelope.pb \
  && echo 'Finished update_in_envelope.pb preparation!' && pkill configtxlator"


  echo $command
  eval $command

  startConfigTxlator ${org} stop

  # now update the channel with the config delta envelop
#  d="cli.$org.$DOMAIN"
#  info " >> $org is generating config tx file update_in_envelope.pb with $d by $command"
#  docker exec ${d} bash -c "$command"
#  info " >> $org successfully generated config tx file update_in_envelope.pb"

    cd ..
  ! [[ -s $GENERATED_ARTIFACTS_FOLDER/config_block.json ]] && echo "$GENERATED_ARTIFACTS_FOLDER/config_block.json is empty. Is configtxlator running?" && exit 1

  command="peer channel update -f update_in_envelope.pb -c $channel -o orderer.$DOMAIN:7050 --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"

  info " >> $org is sending channel update update_in_envelope.pb with $d by $command"
  docker exec ${d} bash -c "$command"
}


#################################
#
# first, downloads new organization config json file from the remote WWW via the specified IP address
# then, prepares config-update envelop by including the new organization into the current network topology config file
# after that, updates channel by
#
#################################
function registerNewOrgInChannel() {
  mainOrg=$1
  new_org=$2
  channel=$3

  info " >> registering org $new_org in channel $channel"

  # update channel config with the help of newOrgMSP.json
  updateChannelConfig ${mainOrg} ${channel} $'\'.[0] * {\"channel_group\":{\"groups\":{\"Application\":{\"groups\": {\"'${new_org}MSP$'\":.[1]}}}}}\' config.json '${new_org}Config.json''

#  # prepare update envelop
#  info " >> next preparing update_${new_org}_in_envelope.pb envelop to include ${new_org} into topology config"
#
#  command="rm -rf ${new_org}_config_block.pb ${new_org}_config_block.json ${new_org}_config.json ${new_org}_config.pb updated_${new_org}_config.json updated_${new_org}_config.pb update_${new_org}.json update_${new_org}.pb update_${new_org}_in_envelope.json \
#  && peer channel fetch config ${new_org}_config_block.pb -o orderer.$DOMAIN:7050 -c $channel --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt \
#  && curl -X POST --data-binary @${new_org}_config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block | jq . > ${new_org}_config_block.json \
#  && echo 'wc for artifacts/${new_org}_config_block.json: $(wc -c < artifacts/${org}_config_block.json)' \
#  && jq .data.data[0].payload.data.config ${new_org}_config_block.json > ${new_org}_config.json \
#  && echo 'wc for artifacts/${new_org}_config.json: $(wc -c < artifacts/${org}_config.json)' \
#  && jq -s '.[0] * {\"channel_group\":{\"groups\":{\"Application\":{\"groups\": {\"${new_org}MSP\":.[1]}}}}}' ${new_org}_config.json ${new_org}Config.json >& updated_${new_org}_config.json \
#  && echo 'wc for artifacts/updated_${new_org}_config.json: $(wc -c < artifacts/updated_${new_org}_config.json)' \
#  && curl -X POST --data-binary @${new_org}_config.json http://127.0.0.1:7059/protolator/encode/common.Config > ${new_org}_config.pb \
#  && curl -X POST --data-binary @updated_${new_org}_config.json http://127.0.0.1:7059/protolator/encode/common.Config > updated_${new_org}_config.pb \
#  && curl -X POST -F channel=$channel -F 'original=@${new_org}_config.pb' -F 'updated=@updated_${new_org}_config.pb' http://127.0.0.1:7059/configtxlator/compute/update-from-configs > update_${new_org}.pb \
#  && curl -X POST --data-binary @update_${new_org}.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate | jq . > update_${new_org}.json \
#  && echo 'wc for artifacts/update_${new_org}.json: $(wc -c < artifacts/update_${new_org}.json)' \
#  && echo '{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"$channel\",\"type\":2}},\"data\":{\"config_update\":'\`cat update_$new_org.json\`'}}}' | jq . > update_${new_org}_in_envelope.json \
#  && echo 'wc for artifacts/update_${new_org}_in_envelope.json: $(wc -c < artifacts/update_${new_org}_in_envelope.json)' \
#  && curl -X POST --data-binary @update_${new_org}_in_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > update_${new_org}_in_envelope.pb \
#  && echo 'Finished update_${new_org}_in_envelope.pb preparation!' && pkill configtxlator && exit 0"
#
#  # now update the channel with the config delta envelop
#  info " >> $ORG1 is generating config tx file update_${new_org}_in_envelope.pb with $d by $c"
#  docker exec ${d} bash -c "$command"
#  info " >> $ORG1 successfully generated config tx file update_${new_org}_in_envelope.pb"
#
#  ! [[ -s artifacts/${new_org}_config_block.json ]] && echo "artifacts/${new_org}_config_block.json is empty. Is configtxlator running?" && exit 1
#
#  d="cli.$ORG1.$DOMAIN"
#  command="peer channel update -f update_${new_org}_in_envelope.pb -c $channel -o orderer.$DOMAIN:7050 --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
#
#  info " >> $ORG1 is sending channel update update_${new_org}_in_envelope.pb with $d by $command"
#  docker exec ${d} bash -c "$command"
}

function updateSignPolicyForChannel() {
  org=$1
  channel=$2

  policyName="${org}Only"
  orgMsp="${org}MSP"

  policy="{\"${policyName}\": { \
                        \"mod_policy\": \"Admins\", \
                        \"policy\": { \
                          \"type\": 1, \
                          \"value\": { \
                            \"identities\": [ \
                              { \
                                \"principal\": { \
                                  \"msp_identifier\": \"${orgMsp}\", \
                                  \"role\": \"ADMIN\" \
                                }, \
                                \"principal_classification\": \"ROLE\" \
                              } \
                            ], \
                            \"rule\": { \
                              \"n_out_of\": { \
                                \"n\": 1, \
                                \"rules\": [ \
                                  { \
                                    \"signed_by\": 0 \
                                  } \
                                ] \
                              } \
                            }, \
                            \"version\": 0 \
                          } \
                        }, \
                        \"version\": \"1\" \
                      }}"

  d="cli.$org.$DOMAIN"
  echo "${policy}" > $GENERATED_ARTIFACTS_FOLDER/new_policy.json
  updateChannelConfig ${org} ${channel} $'\'.[0] * {\"channel_group\":{\"groups\":{\"Application\":{\"mod_policy\": \"'${policyName}$'\", \"policies\":.[1]}}}}\' config.json new_policy.json'

#  c="echo '$policy' > new_policy.json \
#  && peer channel fetch config config_block.pb -o orderer.$DOMAIN:7050 -c $channel --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt \
#  && curl -X POST --data-binary @config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block | jq . > config_block.json \
#  && jq .data.data[0].payload.data.config config_block.json > config.json \
#  && jq -s '.[0] * {\"channel_group\":{\"groups\":{\"Application\":{\"mod_policy\": \"${policyName}\", \"policies\":.[1]}}}}' config.json new_policy.json >& updated_config.json \
#  \
#  && curl -X POST --data-binary @config.json http://127.0.0.1:7059/protolator/encode/common.Config > config.pb \
#  && curl -X POST --data-binary @updated_config.json http://127.0.0.1:7059/protolator/encode/common.Config > updated_config.pb \
#  && curl -X POST -F channel=$channel -F 'original=@config.pb' -F 'updated=@updated_config.pb' http://127.0.0.1:7059/configtxlator/compute/update-from-configs > update.pb \
#  && curl -X POST --data-binary @update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate | jq . > update.json \
#  && echo '{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"$channel\",\"type\":2}},\"data\":{\"config_update\":'\`cat update.json\`'}}}' | jq . > update_in_envelope.json \
#  && curl -X POST --data-binary @update_in_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > update_in_envelope.pb \
#  && pkill configtxlator"
#
#  info "$org is generating config tx file update_in_envelope.pb with $d by $c"
#  docker exec ${d} bash -c "$c"
#
#  c="peer channel update -f update_in_envelope.pb -c $channel -o orderer.$DOMAIN:7050 --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
#
#  info "$ORG1 is sending channel update update_in_envelope.pb with $d by $c"
#  docker exec ${d} bash -c "$c"

}

function devNetworkUp () {
  docker-compose -f ${COMPOSE_FILE_DEV} up -d 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start network"
    logs
    exit 1
  fi
}

function devNetworkDown () {
  docker-compose -f ${COMPOSE_FILE_DEV} down
}

function devInstall () {
  docker-compose -f ${COMPOSE_FILE_DEV} run cli bash -c "peer chaincode install -p relationship -n mycc -v 0"
}

function devInstantiate () {
  docker-compose -f ${COMPOSE_FILE_DEV} run cli bash -c "peer chaincode instantiate -n mycc -v 0 -C myc -c '{\"Args\":[\"init\",\"a\",\"999\",\"b\",\"100\"]}'"
}

function devInvoke () {
  docker-compose -f ${COMPOSE_FILE_DEV} run cli bash -c "peer chaincode invoke -n mycc -v 0 -C myc -c '{\"Args\":[\"move\",\"a\",\"b\",\"10\"]}'"
}

function devQuery () {
  docker-compose -f ${COMPOSE_FILE_DEV} run cli bash -c "peer chaincode query -n mycc -v 0 -C myc -c '{\"Args\":[\"query\",\"a\"]}'"
}

function info() {
    #figlet $1
    echo "*************************************************************************************************************"
    echo "$1"
    echo "*************************************************************************************************************"
}

function logs () {
  f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-$1.yaml"

  TIMEOUT=${CLI_TIMEOUT} COMPOSE_HTTP_TIMEOUT=${CLI_TIMEOUT} docker-compose -f ${f} logs -f
}

function devLogs () {
  TIMEOUT=${CLI_TIMEOUT} COMPOSE_HTTP_TIMEOUT=${CLI_TIMEOUT} docker-compose -f ${COMPOSE_FILE_DEV} logs -f
}

function clean() {
#  removeDockersFromAllCompose
  removeDockersWithDomain
  removeUnwantedImages
  removeArtifacts
  docker volume prune -f
}

function generateWait() {
  echo "$(date --rfc-3339='seconds' -u) *** Wait for 7 minutes to make sure the certificates become active ***"
  sleep 7m
}

function printArgs() {
  echo "$DOMAIN, $ORG1, $ORG2, $ORG3, $IP1, $IP2, $IP3"
}

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  network.sh -m up|down|restart|generate"
  echo "  network.sh -h|--help (print this message)"
  echo "    -m <mode> - one of 'up', 'down', 'restart' or 'generate'"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "      - 'restart' - restart the network"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'logs' - print and follow all docker instances log files"
  echo
  echo "Typically, one would first generate the required certificates and "
  echo "genesis block, then bring up the network. e.g.:"
  echo
  echo "	sudo network.sh -m generate"
  echo "	network.sh -m up"
  echo "	network.sh -m logs"
  echo "	network.sh -m down"
}

# Parse commandline args
while getopts "h?m:o:a:w:c:0:1:2:3:k:v:i:n:M:I:R:P:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    m)  MODE=$OPTARG
    ;;
    v)  CHAINCODE_VERSION=$OPTARG
    ;;
    o)  ORG=$OPTARG
    ;;
    M)  MAIN_ORG=$OPTARG
    ;;
    a)  API_PORT=$OPTARG
    ;;
    w)  WWW_PORT=$OPTARG
    ;;
    c)  CA_PORT=$OPTARG
    ;;
    0)  PEER0_PORT=$OPTARG
    ;;
    1)  PEER0_EVENT_PORT=$OPTARG
    ;;
    2)  PEER1_PORT=$OPTARG
    ;;
    3)  PEER1_EVENT_PORT=$OPTARG
    ;;
    k)  CHANNELS=$OPTARG
    ;;
    i) IP=$OPTARG
    ;;
    n) CHAINCODE=$OPTARG
    ;;
    I) CHAINCODE_INIT_ARG=$OPTARG
    ;;
    R) REMOTE_ORG=$OPTARG
    ;;
    P) ENDORSEMENT_POLICY=$OPTARG
    ;;
  esac
done

if [ "${MODE}" == "up" -a "${ORG}" == "" ]; then
  for org in ${DOMAIN} ${ORG1} ${ORG2} ${ORG3}
  do
    dockerComposeUp ${org}
  done

  for org in ${ORG1} ${ORG2} ${ORG3}
  do
    installAll ${org}
  done

  createJoinInstantiateWarmUp ${ORG1} common ${CHAINCODE_COMMON_NAME} ${CHAINCODE_COMMON_INIT}
  createJoinInstantiateWarmUp ${ORG1} "${ORG1}-${ORG2}" ${CHAINCODE_BILATERAL_NAME} ${CHAINCODE_BILATERAL_INIT}
  createJoinInstantiateWarmUp ${ORG1} "${ORG1}-${ORG3}" ${CHAINCODE_BILATERAL_NAME} ${CHAINCODE_BILATERAL_INIT}

  joinWarmUp ${ORG2} common ${CHAINCODE_COMMON_NAME}
  joinWarmUp ${ORG2} "${ORG1}-${ORG2}" ${CHAINCODE_BILATERAL_NAME}
  createJoinInstantiateWarmUp ${ORG2} "${ORG2}-${ORG3}" ${CHAINCODE_BILATERAL_NAME} ${CHAINCODE_BILATERAL_INIT}

  joinWarmUp ${ORG3} common ${CHAINCODE_COMMON_NAME}
  joinWarmUp ${ORG3} "${ORG1}-${ORG3}" ${CHAINCODE_BILATERAL_NAME}
  joinWarmUp ${ORG3} "${ORG2}-${ORG3}" ${CHAINCODE_BILATERAL_NAME}

elif [ "${MODE}" == "down" ]; then
  for org in ${DOMAIN} ${ORG1} ${ORG2} ${ORG3}
  do
    dockerComposeDown ${org}
  done

  removeUnwantedContainers
  removeUnwantedImages
elif [ "${MODE}" == "clean" ]; then
  clean
elif [ "${MODE}" == "generate" ]; then
  clean
  removeArtifacts

  generatePeerArtifacts ${ORG1} 4000 8081 7054 7051 7053 7056 7058
  generatePeerArtifacts ${ORG2} 4001 8082 8054 8051 8053 8056 8058
  generatePeerArtifacts ${ORG3} 4002 8083 9054 9051 9053 9056 9058
  generateOrdererDockerCompose ${ORG1}
  generateOrdererArtifacts
  #generateWait
elif [ "${MODE}" == "generate-orderer" ]; then  # params: -M ORG (optional)
  generateOrdererDockerCompose ${MAIN_ORG}
  downloadArtifactsOrderer ${MAIN_ORG}
  generateOrdererArtifacts ${MAIN_ORG}
elif [ "${MODE}" == "generate-peer" ]; then # params: -o ORG -R true(optional- REMOTE_ORG)
  generatePeerArtifacts ${ORG} ${API_PORT} ${WWW_PORT} ${CA_PORT} ${PEER0_PORT} ${PEER0_EVENT_PORT} ${PEER1_PORT} ${PEER1_EVENT_PORT}
  servePeerArtifacts ${ORG}
  if [ -n "$REMOTE_ORG" ]; then
    addOrgToCliHosts ${ORG} "orderer" ${IP_ORDERER}
    addOrgToCliHosts ${ORG} "www" ${IP_ORDERER}
    echo "$IP_ORDERER orderer.$DOMAIN" >> $GENERATED_ARTIFACTS_FOLDER/hosts/${thisOrg}/api_hosts
  fi
elif [ "${MODE}" == "up-orderer" ]; then
  dockerComposeUp ${DOMAIN}
  serveOrdererArtifacts
elif [ "${MODE}" == "up-one-org" ]; then # params: -o ORG -M mainOrg -k CHANNELS(optional)
  downloadArtifactsMember ${ORG} ${MAIN_ORG} "" $CHANNELS
  dockerComposeUp ${ORG}
  if [[ -n "$CHANNELS" ]]; then
    createChannel ${ORG} $CHANNELS
    joinChannel ${ORG} $CHANNELS
  fi
elif [ "${MODE}" == "update-sign-policy" ]; then # params: -o ORG -k common_channel
  updateSignPolicyForChannel $ORG $CHANNELS

elif [ "${MODE}" == "register-new-org" ]; then # params: -o ORG -M MAIN_ORG -i IP; example: ./network.sh -m register-new-org -o testOrg -i 172.12.34.56
  [[ -z "${ORG}" ]] && echo "missing required argument -o ORG: organization name to register in system" && exit 1
  [[ -z "${MAIN_ORG}" ]] && echo "missing required argument -M MAIN_ORG: main organization id" && exit 1
  [[ -z "${IP}" ]] && echo "missing required argument -i IP: ip address of the machine being registered" && exit 1
  addOrgToCliHosts ${MAIN_ORG} "www.${ORG}" ${IP}
  downloadArtifactsMember ${MAIN_ORG} ${MAIN_ORG} ${ORG}
  downloadMemberMSP ${ORG}

  registerNewOrg ${ORG} ${MAIN_ORG} ${IP} "$CHANNELS"
  addOrgToNetworkConfig ${ORG}
  copyNetworkConfigToWWW
  addOrgToApiHosts ${MAIN_ORG} ${ORG} ${IP}
  dockerContainerRestart ${MAIN_ORG} api
elif [ "${MODE}" == "add-org-connectivity" ]; then # params: -R remoteOrg -M mainOrg -o thisOrg -i IP
  [[ -z "${ORG}" ]] && echo "missing required argument -o ORG: organization name to register in system" && exit 1
  [[ -z "${MAIN_ORG}" ]] && echo "missing required argument -M MAIN_ORG: main organization id" && exit 1
  [[ -z "${REMOTE_ORG}" ]] && echo "missing required argument -R REMOTE_ORG: org id to define connection to" && exit 1
  [[ -z "${IP}" ]] && echo "missing required argument -i IP: ip address of the REMOTE_ORG (machine connection is established to)" && exit 1

  addOrgToCliHosts $ORG "www.$REMOTE_ORG" $IP
  downloadArtifactsMember ${ORG} ${MAIN_ORG} ${REMOTE_ORG}
  addOrgToApiHosts $ORG $REMOTE_ORG $IP
  dockerContainerRestart ${ORG} api
elif [ "${MODE}" == "restart-api" ]; then # params:  -o ORG
  dockerContainerRestart $ORG api
elif [ "${MODE}" == "create-channel" ]; then # params: mainOrg($3) channel_name org1 [org2] [org3]
  mainOrg=$3
  channel_name=$4
  generateChannelConfig ${@:3}
  createChannel $3 $channel_name
  joinChannel $3 $channel_name
  echo "Register Orgs in channel $channel_name: ${@:5}"
  for org in "${@:5}"; do
    sleep 1
    registerNewOrgInChannel $mainOrg $org $channel_name
  done

elif [ "${MODE}" == "register-org-in-channel" ]; then # params: mainOrg($3) channel_name org1 [org2] [org3]
  mainOrg=$3
  channel_name=$4
  echo "Register Orgs in channel $channel_name: ${@:5}"
  for org in "${@:5}"; do
    echo "Org ${org}"
    registerNewOrgInChannel $mainOrg $org $channel_name
  done

elif [ "${MODE}" == "join-channel" ]; then # params: thisOrg mainOrg channel
  downloadChannelBlockFile ${@:3}
  joinChannel ${3} $5
elif [ "${MODE}" == "install-chaincode" ]; then # example: install-chaincode -o nsd -v 2.0 -n book
  [[ -z "${ORG}" ]] && echo "missing required argument -o ORG: organization name to install chaincode into" && exit 1
  [[ -z "${CHAINCODE}" ]] && echo "missing required argument -n CHAINCODE: chaincode name to install" && exit 1
  [[ -z "${CHAINCODE_VERSION}" ]] && echo "missing required argument -v CHAINCODE_VERSION: chaincode version" && exit 1
  echo "Install chaincode: $ORG ${CHAINCODE} ${CHAINCODE_VERSION}"
  sleep 1
  installChaincode ${ORG} ${CHAINCODE} ${CHAINCODE_VERSION}

elif [ "${MODE}" == "instantiate-chaincode" ]; then # example: instantiate-chaincode -o nsd -k common -n book
  [[ -z "${ORG}" ]] && echo "missing required argument -o ORG: organization name to install chaincode into" && exit 1
  [[ -z "${CHAINCODE}" ]] && echo "missing required argument -d CHAINCODE: chaincode name to install" && exit 1
  [[ -z "${CHANNELS}" ]] && echo "missing required argument -k CHANNELS: channels list" && exit 1
  [[ -z "${CHAINCODE_INIT_ARG}" ]] && CHAINCODE_INIT_ARG=${CHAINCODE_COMMON_INIT}
  sleep 1
  instantiateChaincode ${ORG} "${CHANNELS}" ${CHAINCODE} ${CHAINCODE_INIT_ARG}

elif [ "${MODE}" == "warmup-chaincode" ]; then # example: instantiate-chaincode -o nsd -k common -n book
  [[ -z "${ORG}" ]] && echo "missing required argument -o ORG: organization name to install chaincode into" && exit 1
  [[ -z "${CHAINCODE}" ]] && echo "missing required argument -d CHAINCODE: chaincode name to install" && exit 1
  [[ -z "${CHANNELS}" ]] && echo "missing required argument -k CHANNELS: channels" && exit 1
  [[ -z "${CHAINCODE_INIT_ARG}" ]] && echo "missing required argument -I CHAINCODE_QUERY_ARG: chaincode query args" && exit 1
  sleep 3
  warmUpChaincode ${ORG} "${CHANNELS}" ${CHAINCODE} ${CHAINCODE_INIT_ARG}
elif [ "${MODE}" == "up-1" ]; then
  downloadArtifactsMember ${ORG1} "" "" common "${ORG1}-${ORG2}" "${ORG1}-${ORG3}"
  dockerComposeUp ${ORG1}
  installAll ${ORG1}

  createJoinInstantiateWarmUp ${ORG1} common ${CHAINCODE_COMMON_NAME} ${CHAINCODE_COMMON_INIT}

  createJoinInstantiateWarmUp ${ORG1} "${ORG1}-${ORG2}" ${CHAINCODE_BILATERAL_NAME} ${CHAINCODE_BILATERAL_INIT}

  createJoinInstantiateWarmUp ${ORG1} "${ORG1}-${ORG3}" ${CHAINCODE_BILATERAL_NAME} ${CHAINCODE_BILATERAL_INIT}

elif [ "${MODE}" == "up-2" ]; then
  downloadArtifactsMember ${ORG2} "" "" common "${ORG1}-${ORG2}" "${ORG2}-${ORG3}"
  dockerComposeUp ${ORG2}
  installAll ${ORG2}

  downloadChannelBlockFile ${ORG2} ${ORG1} common
  joinWarmUp ${ORG2} common ${CHAINCODE_COMMON_NAME}

  downloadChannelBlockFile ${ORG2} ${ORG1} "${ORG1}-${ORG2}"
  joinWarmUp ${ORG2} "${ORG1}-${ORG2}" ${CHAINCODE_BILATERAL_NAME}

  createJoinInstantiateWarmUp ${ORG2} "${ORG2}-${ORG3}" ${CHAINCODE_BILATERAL_NAME} ${CHAINCODE_BILATERAL_INIT}

elif [ "${MODE}" == "up-3" ]; then
  downloadArtifactsMember ${ORG3} "" "" common "${ORG1}-${ORG3}" "${ORG2}-${ORG3}"
  dockerComposeUp ${ORG3}
  installAll ${ORG3}

  downloadChannelBlockFile ${ORG3} ${ORG1} common
  joinWarmUp ${ORG3} common ${CHAINCODE_COMMON_NAME}

  downloadChannelBlockFile ${ORG3} ${ORG2} "${ORG2}-${ORG3}"
  joinWarmUp ${ORG3} "${ORG2}-${ORG3}" ${CHAINCODE_BILATERAL_NAME}

  downloadChannelBlockFile ${ORG3} ${ORG1} "${ORG1}-${ORG3}"
  joinWarmUp ${ORG3} "${ORG1}-${ORG3}" ${CHAINCODE_BILATERAL_NAME}

elif [ "${MODE}" == "addOrg" ]; then
  [[ -z "${ORG}" ]] && echo "missing required argument -o ORG" && exit 1
  [[ -z "${CHANNELS}" ]] && echo "missing required argument -k CHANNEL" && exit 1

  #./network.sh -m addOrg -o foo -k common -a 4003 -w 8084 -c 1054 -0 1051 -1 1053 -2 1056 -3 1058

  addOrg ${ORG} ${CHANNELS}

elif [ "${MODE}" == "logs" ]; then
  logs ${ORG}
elif [ "${MODE}" == "devup" ]; then
  devNetworkUp
elif [ "${MODE}" == "devinstall" ]; then
  devInstall
elif [ "${MODE}" == "devinstantiate" ]; then
  devInstantiate
elif [ "${MODE}" == "devinvoke" ]; then
  devInvoke
elif [ "${MODE}" == "devquery" ]; then
  devQuery
elif [ "${MODE}" == "devlogs" ]; then
  devLogs
elif [ "${MODE}" == "devdown" ]; then
  devNetworkDown
elif [ "${MODE}" == "printArgs" ]; then
  printArgs
elif [ "${MODE}" == "iterateChannels" ]; then
  iterateChannels
elif [ "${MODE}" == "removeArtifacts" ]; then
  removeArtifacts
elif [ "${MODE}" == "generateNetworkConfig" ]; then
  [[ -z "$3" ]] && generateNetworkConfig ${ORG1} ${ORG2} ${ORG3}
  [[ -n "$3" ]] && generateNetworkConfig ${@:3}
elif [ "${MODE}" == "addOrgToNetworkConfig" ]; then # -o ORG
  addOrgToNetworkConfig ${ORG}
elif [ "${MODE}" == "upgradeChaincode" ]; then #deprecated
  for org in ${ORG1} ${ORG2} ${ORG3}
  do
    upgradeChaincode ${org} ${CHAINCODE_COMMON_NAME} ${CHAINCODE_VERSION}
  done
elif [ "${MODE}" == "upgrade-chaincode" ]; then
  [[ -z "${ORG}" ]] && echo "missing required argument -o ORG: organization name to install chaincode into" && exit 1
  [[ -z "${CHAINCODE}" ]] && echo "missing required argument -d CHAINCODE: chaincode name to install" && exit 1
  [[ -z "${CHAINCODE_VERSION}" ]] && echo "missing required argument -v CHAINCODE_VERSION: chaincode version" && exit 1
  [[ -z "${CHAINCODE_INIT_ARG}" ]] && echo "missing required argument -I CHAINCODE_INIT_ARG: chaincode initialization arguments" && exit 1
  [[ -z "${CHANNELS}" ]] && echo "missing required argument -k CHANNEL" && exit 1
  echo "Upgrading with endorsement policy: ${ENDORSEMENT_POLICY}"
  upgradeChaincode ${ORG} ${CHAINCODE} ${CHAINCODE_VERSION} ${CHAINCODE_INIT_ARG} ${CHANNELS} ${ENDORSEMENT_POLICY}
else
  printHelp
  exit 1
fi

endtime=$(date +%s)
info "Finished in $(($endtime - $starttime)) seconds"
