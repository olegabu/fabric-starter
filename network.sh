#!/usr/bin/env bash

starttime=$(date +%s)

# defaults; export these variables before executing this script
: ${DOMAIN:="example.com"}
: ${IP_ORDERER:="54.235.3.243"}
: ${ORG1:="a"}
: ${ORG2:="b"}
: ${ORG3:="c"}
: ${IP1:="34.227.26.187"}
: ${IP2:="34.207.72.186"}
: ${IP3:="54.226.46.207"}

WGET_OPTS="--verbose -N"
CLI_TIMEOUT=10000
COMPOSE_TEMPLATE=ledger/docker-composetemplate.yaml
COMPOSE_FILE_DEV=ledger/docker-composedev.yaml

CHAINCODE_COMMON_NAME=reference
CHAINCODE_BILATERAL_NAME=relationship
CHAINCODE_COMMON_INIT='{"Args":["init","a","100","b","100"]}'
CHAINCODE_BILATERAL_INIT='{"Args":["init","a","100","b","100"]}'
CHAINCODE_WARMUP_QUERY='{\"Args\":[\"query\"]}'

DEFAULT_ORDERER_PORT=7050
DEFAULT_WWW_PORT=8080
DEFAULT_API_PORT=4000
DEFAULT_CA_PORT=7054
DEFAULT_PEER0_PORT=7051
DEFAULT_PEER0_EVENT_PORT=7053
DEFAULT_PEER1_PORT=7056
DEFAULT_PEER1_EVENT_PORT=7058

DEFAULT_ORDERER_EXTRA_HOSTS="extra_hosts:\\n      - peer0.$ORG1.$DOMAIN:$IP1\\n      - peer0.$ORG2.$DOMAIN:$IP2\\n      - peer0.$ORG3.$DOMAIN:$IP3"
DEFAULT_PEER_EXTRA_HOSTS="extra_hosts:\\n      - orderer.$DOMAIN:$IP_ORDERER"
DEFAULT_CLI_EXTRA_HOSTS="extra_hosts:\\n      - orderer.$DOMAIN:$IP_ORDERER\\n      - www.$DOMAIN:$IP_ORDERER\\n      - www.$ORG1.$DOMAIN:$IP1\\n      - www.$ORG2.$DOMAIN:$IP2\\n      - www.$ORG3.$DOMAIN:$IP3"
DEFAULT_API_EXTRA_HOSTS1="extra_hosts:\\n      - orderer.$DOMAIN:$IP_ORDERER\\n      - peer0.$ORG2.$DOMAIN:$IP2\\n      - peer0.$ORG3.$DOMAIN:$IP3"
DEFAULT_API_EXTRA_HOSTS2="extra_hosts:\\n      - orderer.$DOMAIN:$IP_ORDERER\\n      - peer0.$ORG1.$DOMAIN:$IP1\\n      - peer0.$ORG3.$DOMAIN:$IP3"
DEFAULT_API_EXTRA_HOSTS3="extra_hosts:\\n      - orderer.$DOMAIN:$IP_ORDERER\\n      - peer0.$ORG1.$DOMAIN:$IP1\\n      - peer0.$ORG2.$DOMAIN:$IP2"

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
  echo "Removing generated and downloaded artifacts"
  rm ledger/docker-compose-*.yaml
  rm -rf artifacts/crypto-config
  rm -rf artifacts/channel
  rm artifacts/*block*
  rm -rf www/artifacts && mkdir www/artifacts
}

function removeDockersFromCompose() {
    for o in ${DOMAIN} ${ORG1} ${ORG2} ${ORG3}
    do
      f="ledger/docker-compose-$o.yaml"

      if [ -f ${f} ]; then
        echo "Removing docker containers listed in $f"
        docker-compose -f ${f} kill
        docker-compose -f ${f} rm -f
      fi;
    done
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

function generateOrdererDockerCompose() {
    echo "Creating orderer docker compose yaml file with $DOMAIN, $ORG1, $ORG2, $ORG3, $DEFAULT_ORDERER_PORT, $DEFAULT_WWW_PORT"

    f="ledger/docker-compose-$DOMAIN.yaml"
    compose_template=ledger/docker-composetemplate-orderer.yaml

    cli_extra_hosts=${DEFAULT_CLI_EXTRA_HOSTS}

    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/CLI_EXTRA_HOSTS/$cli_extra_hosts/g" -e "s/ORDERER_PORT/$DEFAULT_ORDERER_PORT/g" -e "s/WWW_PORT/$DEFAULT_WWW_PORT/g" -e "s/ORG1/$ORG1/g" -e "s/ORG2/$ORG2/g" -e "s/ORG3/$ORG3/g" ${compose_template} > ${f}
}

function generateOrdererArtifacts() {
    echo "Creating orderer yaml files with $DOMAIN, $ORG1, $ORG2, $ORG3, $DEFAULT_ORDERER_PORT, $DEFAULT_WWW_PORT"

    f="ledger/docker-compose-$DOMAIN.yaml"

    # replace in configtx
    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/$ORG1/g" -e "s/ORG2/$ORG2/g" -e "s/ORG3/$ORG3/g" artifacts/configtxtemplate.yaml > artifacts/configtx.yaml

    # replace in cryptogen
    sed -e "s/DOMAIN/$DOMAIN/g" artifacts/cryptogentemplate-orderer.yaml > artifacts/"cryptogen-$DOMAIN.yaml"

    # replace in network-config.json
    sed -e "s/\DOMAIN/$DOMAIN/g" -e "s/\ORG1/$ORG1/g" -e "s/\ORG2/$ORG2/g" -e "s/\ORG3/$ORG3/g" -e "s/^\s*\/\/.*$//g" artifacts/network-config-template.json > artifacts/network-config.json

    echo "Generating crypto material with cryptogen"
    docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "cryptogen generate --config=cryptogen-$DOMAIN.yaml"

    echo "Generating orderer genesis block with configtxgen"
    mkdir -p artifacts/channel
    docker-compose --file ${f} run --rm -e FABRIC_CFG_PATH=/etc/hyperledger/artifacts "cli.$DOMAIN" configtxgen -profile OrdererGenesis -outputBlock ./channel/genesis.block

    for channel_name in common "$ORG1-$ORG2" "$ORG1-$ORG3" "$ORG2-$ORG3"
    do
        echo "Generating channel config transaction for $channel_name"
        docker-compose --file ${f} run --rm -e FABRIC_CFG_PATH=/etc/hyperledger/artifacts "cli.$DOMAIN" configtxgen -profile "$channel_name" -outputCreateChannelTx "./channel/$channel_name.tx" -channelID "$channel_name"
    done

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

    f="ledger/docker-compose-$org.yaml"
    compose_template=ledger/docker-composetemplate-peer.yaml

    # cryptogen
    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$org/g" artifacts/cryptogentemplate-peer.yaml > artifacts/"cryptogen-$org.yaml"

    # docker-compose.yaml
    sed -e "s/PEER_EXTRA_HOSTS/$peer_extra_hosts/g" -e "s/CLI_EXTRA_HOSTS/$cli_extra_hosts/g" -e "s/API_EXTRA_HOSTS/$api_extra_hosts/g" -e "s/DOMAIN/$DOMAIN/g" -e "s/\([^ ]\)ORG/\1$org/g" -e "s/API_PORT/$api_port/g" -e "s/WWW_PORT/$www_port/g" -e "s/CA_PORT/$ca_port/g" -e "s/PEER0_PORT/$peer0_port/g" -e "s/PEER0_EVENT_PORT/$peer0_event_port/g" -e "s/PEER1_PORT/$peer1_port/g" -e "s/PEER1_EVENT_PORT/$peer1_event_port/g" ${compose_template} > ${f}

    # fabric-ca-server-config.yaml
    sed -e "s/ORG/$org/g" artifacts/fabric-ca-server-configtemplate.yaml > artifacts/"fabric-ca-server-config-$org.yaml"

    echo "Generating crypto material with cryptogen"
    docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "cryptogen generate --config=cryptogen-$org.yaml"

    echo "Changing artifacts ownership"
    docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "chown -R $UID:$GID ."

    echo "Adding generated CA private keys filenames to $f"
    ca_private_key=$(basename `ls artifacts/crypto-config/peerOrganizations/"$org.$DOMAIN"/ca/*_sk`)
    [[ -z  ${ca_private_key}  ]] && echo "empty CA private key" && exit 1
    sed -i -e "s/CA_PRIVATE_KEY/${ca_private_key}/g" ${f}
}

function servePeerArtifacts() {
    org=$1
    f="ledger/docker-compose-$org.yaml"

    d="artifacts/crypto-config/peerOrganizations/$org.$DOMAIN/peers/peer0.$org.$DOMAIN/tls"
    echo "Copying generated TLS cert files from $d to be served by www.$org.$DOMAIN"
    mkdir -p "www/${d}"
    cp "${d}/ca.crt" "www/${d}"

    d="artifacts/crypto-config/peerOrganizations/$org.$DOMAIN"
    echo "Copying generated MSP cert files from $d to be served by www.$org.$DOMAIN"
    cp -r "${d}/msp" "www/${d}"

    docker-compose --file ${f} up -d "www.$org.$DOMAIN"
}

function serveOrdererArtifacts() {
    f="ledger/docker-compose-$DOMAIN.yaml"

    d="artifacts/crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/tls"
    echo "Copying generated orderer TLS cert files from $d to be served by www.$DOMAIN"
    mkdir -p "www/${d}"
    cp "${d}/ca.crt" "www/${d}"

    d="artifacts"
    echo "Copying generated network config file from $d to be served by www.$DOMAIN"
    cp "${d}/network-config.json" "www/${d}"

    d="artifacts/channel"
    echo "Copying channel transaction config files from $d to be served by www.$DOMAIN"
    mkdir -p "www/${d}"
    cp "${d}/"*.tx "www/${d}/"

    docker-compose --file ${f} up -d "www.$DOMAIN"
}

function createChannel () {
    org=$1
    channel_name=$2
    f="ledger/docker-compose-${org}.yaml"

    info "creating channel $channel_name by $org using $f"

    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "peer channel create -o orderer.$DOMAIN:7050 -c $channel_name -f /etc/hyperledger/artifacts/channel/$channel_name.tx --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"

    echo "changing ownership of channel block files"
    docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "chown -R $UID:$GID ."

    d="artifacts"
    echo "copying channel block file from ${d} to be served by www.$org.$DOMAIN"
    cp "${d}/$channel_name.block" "www/${d}"
}

function joinChannel() {
    org=$1
    channel_name=$2
    f="ledger/docker-compose-${org}.yaml"

    info "joining channel $channel_name by all peers of $org using $f"

    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer channel join -b $channel_name.block"
    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "CORE_PEER_ADDRESS=peer1.$org.$DOMAIN:7051 peer channel join -b $channel_name.block"
}

function instantiateChaincode () {
    org=$1
    channel_name=$2
    n=$3
    i=$4
    f="ledger/docker-compose-${org}.yaml"

    info "instantiating chaincode $n on $channel_name by $org using $f with $i"

    c="CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode instantiate -n $n -v 1.0 -c '$i' -o orderer.$DOMAIN:7050 -C $channel_name --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
    echo ${c}

    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c}"
}

function warmUpChaincode () {
    org=$1
    channel_name=$2
    n=$3
    f="ledger/docker-compose-${org}.yaml"

    info "warming up chaincode $n on $channel_name on all peers of $org with query using $f"

    c="CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode query -n $n -v 1.0 -c $CHAINCODE_WARMUP_QUERY -C $channel_name"
    i="cli.$org.$DOMAIN"
    echo ${i}
    echo ${c}

    docker-compose --file ${f} run --rm ${i} bash -c "${c}"
}

function installChaincode() {
    org=$1
    n=$2
    # chaincode path is the same as chaincode name by convention: code of chaincode instruction lives in ./chaincode/go/instruction mapped to docker path /opt/gopath/src/instruction
    p=${n}
    f="ledger/docker-compose-${org}.yaml"

    info "installing chaincode $n to peers of $org from ./chaincode/go/$p using $f"

    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode install -n $n -v 1.0 -p $p && CORE_PEER_ADDRESS=peer1.$org.$DOMAIN:7051 peer chaincode install -n $n -v 1.0 -p $p"
}

function dockerComposeUp () {
  compose_file="ledger/docker-compose-$1.yaml"

  info "starting docker instances from $compose_file"

  TIMEOUT=${CLI_TIMEOUT} docker-compose -f ${compose_file} up -d 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start network"
    logs ${1}
    exit 1
  fi
}

function dockerComposeDown () {
  compose_file="ledger/docker-compose-$1.yaml"

  if [ -f ${compose_file} ]; then
      info "stopping docker instances from $compose_file"
      docker-compose -f ${compose_file} down
  fi;

}

function installAll() {
  org=$1

  for chaincode_name in ${CHAINCODE_COMMON_NAME} ${CHAINCODE_BILATERAL_NAME}
  do
    installChaincode ${org} ${chaincode_name}
  done
}

#function installInstantiateWarmUp() {
#  org=$1
#  channel_name=$2
#  chaincode_name=$3
#  chaincode_init=$4
#
#  installChaincode ${org} ${chaincode_name}
#  instantiateWarmUp ${org} ${channel_name} ${chaincode_name} ${chaincode_init}
#}

#function instantiateWarmUp() {
#  org=$1
#  channel_name=$2
#  chaincode_name=$3
#  chaincode_init=$4
#
#  instantiateChaincode ${org} ${channel_name} ${chaincode_name} ${chaincode_init}
#  sleep 7
#  warmUpChaincode ${org} ${channel_name} ${chaincode_name}
#}

function joinWarmUp() {
  org=$1
  channel_name=$2
  chaincode_name=$3

  joinChannel ${org} ${channel_name}
  sleep 7
  warmUpChaincode ${org} ${channel_name} ${chaincode_name}
}

function createJoinInstantiateWarmUp() {
  org=${1}
  channel_name=${2}
  chaincode_name=${3}
  chaincode_init=${4}

  createChannel ${org} ${channel_name}
  joinChannel ${org} ${channel_name}
  instantiateChaincode ${org} ${channel_name} ${chaincode_name} ${chaincode_init}
  sleep 7
  warmUpChaincode ${org} ${channel_name} ${chaincode_name}
}

function makeCertDirs() {
  mkdir -p "artifacts/crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/tls"

  for org in ${ORG1} ${ORG2} ${ORG3}
    do
        d="artifacts/crypto-config/peerOrganizations/$org.$DOMAIN/peers/peer0.$org.$DOMAIN/tls"
        echo "mkdir -p ${d}"
        mkdir -p ${d}
    done
}

function downloadMemberMSP() {
    f="ledger/docker-compose-$DOMAIN.yaml"

    info "downloading member MSP files using $f"

    c="for ORG in ${ORG1} ${ORG2} ${ORG3}; do wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/admincerts http://www.\$ORG.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/admincerts/Admin@\$ORG.$DOMAIN-cert.pem && wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/cacerts http://www.\$ORG.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/cacerts/ca.\$ORG.$DOMAIN-cert.pem && wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/tlscacerts http://www.\$ORG.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\$ORG.$DOMAIN/msp/tlscacerts/tlsca.\$ORG.$DOMAIN-cert.pem; done"
    echo ${c}
    docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."
}

function downloadNetworkConfig() {
    org=$1
    f="ledger/docker-compose-$org.yaml"

    info "downloading network config file using $f"

    c="wget ${WGET_OPTS} http://www.$DOMAIN:$DEFAULT_WWW_PORT/network-config.json && chown -R $UID:$GID ."
    echo ${c}
    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c}"
}

function downloadChannelTxFiles() {
    org=$1
    f="ledger/docker-compose-$org.yaml"

    info "downloading all channel config transaction files using $f"

    for channel_name in ${@:2}
    do
      c="wget ${WGET_OPTS} --directory-prefix channel http://www.$DOMAIN:$DEFAULT_WWW_PORT/channel/$channel_name.tx && chown -R $UID:$GID ."
      echo ${c}
      docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c}"
    done
}

function downloadChannelBlockFile() {
    org=$1
    f="ledger/docker-compose-$org.yaml"

    leader=$2
    channel_name=$3

    info "downloading channel block file of created $channel_name from $leader using $f"

    c="wget ${WGET_OPTS} http://www.$leader.$DOMAIN:$DEFAULT_WWW_PORT/$channel_name.block && chown -R $UID:$GID ."
    echo ${c}
    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c}"
}

function downloadArtifactsMember() {
  makeCertDirs

  org=$1
  f="ledger/docker-compose-$org.yaml"

  downloadChannelTxFiles ${@}
  downloadNetworkConfig ${org}

  info "downloading orderer cert file using $f"

  c="wget ${WGET_OPTS} --directory-prefix crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/tls http://www.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer.$DOMAIN/tls/ca.crt"
  echo ${c}
  docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."

  #TODO download not from all members but from the orderer
  info "downloading member cert files using $f"

  c="for ORG in ${ORG1} ${ORG2} ${ORG3}; do wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\${ORG}.$DOMAIN/peers/peer0.\${ORG}.$DOMAIN/tls http://www.\${ORG}.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\${ORG}.$DOMAIN/peers/peer0.\${ORG}.$DOMAIN/tls/ca.crt; done"
  echo ${c}
  docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."
}

function downloadArtifactsOrderer() {
#  for org in ${ORG1} ${ORG2} ${ORG3}
#    do
#      rm -rf "artifacts/crypto-config/peerOrganizations/$org.$DOMAIN"
#    done

  makeCertDirs
  downloadMemberMSP

  f="ledger/docker-compose-$DOMAIN.yaml"

  info "downloading member cert files using $f"

  c="for ORG in ${ORG1} ${ORG2} ${ORG3}; do wget ${WGET_OPTS} --directory-prefix crypto-config/peerOrganizations/\${ORG}.$DOMAIN/peers/peer0.\${ORG}.$DOMAIN/tls http://www.\${ORG}.$DOMAIN:$DEFAULT_WWW_PORT/crypto-config/peerOrganizations/\${ORG}.$DOMAIN/peers/peer0.\${ORG}.$DOMAIN/tls/ca.crt; done"
  echo ${c}
  docker-compose --file ${f} run --rm "cli.$DOMAIN" bash -c "${c} && chown -R $UID:$GID ."
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

function devInstallInstantiate () {
  docker-compose -f ${COMPOSE_FILE_DEV} run cli bash -c "peer chaincode instantiate -n mycc -v 0 -C myc -c '{\"Args\":[\"init\",\"[\"a\",\"10\",\"b\",\"100\"]}'"
}

function devInvoke () {
  docker-compose -f ${COMPOSE_FILE_DEV} run cli bash -c "peer chaincode invoke -n mycc -v 0 -C myc -c '{\"Args\":[\"move\",\"[\"a\",\"b\",\"10\"]}'"
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
  f="ledger/docker-compose-$1.yaml"

  TIMEOUT=${CLI_TIMEOUT} COMPOSE_HTTP_TIMEOUT=${CLI_TIMEOUT} docker-compose -f ${f} logs -f
}

function devLogs () {
  TIMEOUT=${CLI_TIMEOUT} COMPOSE_HTTP_TIMEOUT=${CLI_TIMEOUT} docker-compose -f ${COMPOSE_FILE_DEV} logs -f
}

function clean() {
  removeDockersFromCompose
#  removeDockersWithDomain
  removeUnwantedImages
  removeArtifacts
}

function generateWait() {
  echo "$(date --rfc-3339='seconds' -u) *** Wait for 7 minutes to make sure the certificates become active ***"
  sleep 7m
}

function generatePeerArtifacts1() {
  generatePeerArtifacts ${ORG1} 4000 8081 7054 7051 7053 7056 7058
}

function generatePeerArtifacts2() {
  generatePeerArtifacts ${ORG2} 4001 8082 8054 8051 8053 8056 8058
}

function generatePeerArtifacts3() {
  generatePeerArtifacts ${ORG3} 4002 8083 9054 9051 9053 9056 9058
}

function printArgs() {
  echo "$DOMAIN, $ORG1, $ORG2, $ORG3, $IP1, $IP2, $IP3"
}

function iterateChannels() {
  ORGS="e:198.168.0.5 f:198.168.0.6 b:198.168.0.2 c:198.168.0.3 d:198.168.0.4 a:198.168.0.1"

  orgs=($(for o in ${ORGS}; do echo ${o%:*}; done | sort))
  ips=($(for o in ${ORGS}; do echo ${o#*:}; done | sort))

  declare -A creators joiners
  size=${#orgs[*]}

  for i in ${!orgs[@]}
  do
    creator=${orgs[$i]}
    joiner=${orgs[$i]}
    for j in ${!orgs[@]}
    do
      if (( j > i )); then
        creator+=" ${orgs[$i]}-${orgs[$j]}"
      elif (( j < i )); then
        joiner+=" ${orgs[$j]}-${orgs[$i]}"
      fi
    done
    if (( i < $((size-1)) )); then
      creators[${i}]=${creator}
    fi
    if (( i > 0 )); then
      joiners[${i}]=${joiner}
    fi
  done

  info orgs
  for i in ${!orgs[@]}
  do
    echo ${orgs[$i]}
  done

  info ips
  for i in ${!ips[@]}
  do
    echo ${ips[$i]}
  done

  info creators
  for i in ${!creators[@]}
  do
    echo ${creators[$i]}
  done

  info joiners
  for i in ${!joiners[@]}
  do
    echo ${joiners[$i]}
  done
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
while getopts "h?m:o:a:w:c:0:1:2:3:k:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    m)  MODE=$OPTARG
    ;;
    o)  ORG=$OPTARG
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
  dockerComposeDown ${DOMAIN}
  dockerComposeDown ${ORG1}
  dockerComposeDown ${ORG2}
  dockerComposeDown ${ORG3}
  removeUnwantedContainers
  removeUnwantedImages
elif [ "${MODE}" == "clean" ]; then
  clean
elif [ "${MODE}" == "generate" ]; then
  clean
  generatePeerArtifacts ${ORG1} 4000 8081 7054 7051 7053 7056 7058
  generatePeerArtifacts ${ORG2} 4001 8082 8054 8051 8053 8056 8058
  generatePeerArtifacts ${ORG3} 4002 8083 9054 9051 9053 9056 9058
  generateOrdererDockerCompose
  generateOrdererArtifacts
  generateWait
elif [ "${MODE}" == "generate-orderer" ]; then
  generateOrdererDockerCompose
  downloadArtifactsOrderer
  generateOrdererArtifacts
elif [ "${MODE}" == "generate-peer" ]; then
  generatePeerArtifacts ${ORG} ${API_PORT} ${WWW_PORT} ${CA_PORT} ${PEER0_PORT} ${PEER0_EVENT_PORT} ${PEER1_PORT} ${PEER1_EVENT_PORT}
  servePeerArtifacts ${ORG}
elif [ "${MODE}" == "up-orderer" ]; then
  dockerComposeUp ${DOMAIN}
  serveOrdererArtifacts
elif [ "${MODE}" == "up-1" ]; then
  dockerComposeUp ${ORG1}
  installAll ${ORG1}
  downloadArtifactsMember ${ORG1} common "${ORG1}-${ORG2}" "${ORG1}-${ORG3}"

  createJoinInstantiateWarmUp ${ORG1} common ${CHAINCODE_COMMON_NAME} ${CHAINCODE_COMMON_INIT}

  createJoinInstantiateWarmUp ${ORG1} "${ORG1}-${ORG2}" ${CHAINCODE_BILATERAL_NAME} ${CHAINCODE_BILATERAL_INIT}

  createJoinInstantiateWarmUp ${ORG1} "${ORG1}-${ORG3}" ${CHAINCODE_BILATERAL_NAME} ${CHAINCODE_BILATERAL_INIT}

elif [ "${MODE}" == "up-2" ]; then
  dockerComposeUp ${ORG2}
  installAll ${ORG2}
  downloadArtifactsMember ${ORG2} common "${ORG1}-${ORG2}" "${ORG2}-${ORG3}"

  downloadChannelBlockFile ${ORG2} ${ORG1} common
  joinWarmUp ${ORG2} common ${CHAINCODE_COMMON_NAME}

  downloadChannelBlockFile ${ORG2} ${ORG1} "${ORG1}-${ORG2}"
  joinWarmUp ${ORG2} "${ORG1}-${ORG2}" ${CHAINCODE_BILATERAL_NAME}

  createJoinInstantiateWarmUp ${ORG2} "${ORG2}-${ORG3}" ${CHAINCODE_BILATERAL_NAME} ${CHAINCODE_BILATERAL_INIT}

elif [ "${MODE}" == "up-3" ]; then
  dockerComposeUp ${ORG3}
  installAll ${ORG3}
  downloadArtifactsMember ${ORG3} common "${ORG1}-${ORG3}" "${ORG2}-${ORG3}"

  downloadChannelBlockFile ${ORG3} ${ORG1} common
  joinWarmUp ${ORG3} common ${CHAINCODE_COMMON_NAME}

  downloadChannelBlockFile ${ORG3} ${ORG2} "${ORG2}-${ORG3}"
  joinWarmUp ${ORG3} "${ORG2}-${ORG3}" ${CHAINCODE_BILATERAL_NAME}

  downloadChannelBlockFile ${ORG3} ${ORG1} "${ORG1}-${ORG3}"
  joinWarmUp ${ORG3} "${ORG1}-${ORG3}" ${CHAINCODE_BILATERAL_NAME}

elif [ "${MODE}" == "logs" ]; then
  logs ${ORG}
elif [ "${MODE}" == "devup" ]; then
  devNetworkUp
elif [ "${MODE}" == "devinit" ]; then
  devInstallInstantiate
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
else
  printHelp
  exit 1
fi

endtime=$(date +%s)
echo "Finished in $(($endtime - $starttime)) seconds"
