#!/usr/bin/env bash

: ${DOMAIN:="example.com"}
: ${ORG:="org1"}
: ${WGET_OPTS:="--verbose -N"}
: ${FABRIC_STARTER_HOME:=.}

: ${ORDERER_TLSCA_CERT_OPTS=" --tls --cafile /etc/hyperledger/crypto-config/ordererOrganizations/${DOMAIN}/msp/tlscacerts/tlsca.${DOMAIN}-cert.pem"}


export DOMAIN ORG

function printInColor() {
    color1=$1
    message1=$2
    color2=$3
    message2=$4
    echo -e "\033[${color1}m${message1}\033[m\033[${color2}m$message2\033[m"
}

function printRedYellow() {
    printInColor "1;31" "$1" "1;33" "$2"
}

function printUsage() {
    usageMsg=$1
    exampleMsg=$2
    printRedYellow "\nUsage:" "$usageMsg"
    printRedYellow "\nExample:" "$exampleMsg"
}

function runCLIWithComposerOverrides() {
    local composeCommand=${1:?Compose command must be specified}
    local service=${2}
    local command=${3}
    IFS=' ' composeCommandSplitted=($composeCommand)

    [ -n "$EXECUTE_BY_ORDERER" ] && composeTemplateFile="$FABRIC_STARTER_HOME/docker-compose-orderer.yaml" || composeTemplateFile="$FABRIC_STARTER_HOME/docker-compose.yaml"

    if [ "${MULTIHOST}" ]; then
        [ -n "$EXECUTE_BY_ORDERER" ] && multihostComposeFile="-forderer-multihost.yaml" || multihostComposeFile="-fmultihost.yaml"
    fi

#    if [ "${PORTS}" ]; then
#        [ -n "$EXECUTE_BY_ORDERER" ] && portsComposeFile="-forderer-ports.yaml" || portsComposeFile="-fdocker-compose-ports.yaml"
#    fi

    [ -n "${COUCHDB}" ] && [ -z "$EXECUTE_BY_ORDERER" ] && couchDBComposeFile="-fdocker-compose-couchdb.yaml"
    [ -n "${LDAP_ENABLED}" ] && [ -z "$EXECUTE_BY_ORDERER" ] && ldapComposeFile="-fdocker-compose-ldap.yaml"

    printInColor "1;32" "Execute: docker-compose -f ${composeTemplateFile} ${multihostComposeFile} ${couchDBComposeFile} ${ldapComposeFile} ${composeCommandSplitted[0]} ${composeCommandSplitted[1]} ${service} ${command:+bash -c} $command"
    if [ -n "$command" ]; then
        docker-compose -f "${composeTemplateFile}" ${multihostComposeFile} ${portsComposeFile} ${couchDBComposeFile} ${ldapComposeFile} ${composeCommandSplitted[0]} ${composeCommandSplitted[1]}  ${service} bash -c "${command}"
    else
        docker-compose -f "${composeTemplateFile}" ${multihostComposeFile} ${portsComposeFile} ${couchDBComposeFile} ${ldapComposeFile} ${composeCommandSplitted[0]} ${composeCommandSplitted[1]}  ${service}
    fi

    [ $? -ne 0 ] && printRedYellow "Error occurred. See console output above." && exit 1
}


function runCLI() {
    local command="$1"

    if [ -n "$EXECUTE_BY_ORDERER" ]; then
        service="cli.orderer"
        checkContainer="cli.$DOMAIN"
    else
        service="cli.peer"
        checkContainer="cli.$ORG.$DOMAIN"
    fi

    cliContainerId=`docker ps --filter name=$checkContainer -q`

    # TODO No such command: run __rm when composeCommand="run --rm"
    [ -n "$cliContainerId" ] && composeCommand="exec" || composeCommand="run --rm"

    runCLIWithComposerOverrides "${composeCommand}" "$service" "$command"
}

function envSubst() {
    inputFile=${1:?Input file required}
    outputFile=${2:?Output file required}
    local extraEnvironment=${3:-true}

    runCLI "$extraEnvironment && envsubst <$inputFile >$outputFile && chown $UID $outputFile"
}


function downloadMSP() {
    org=$1

    if [ -n "$EXECUTE_BY_ORDERER" ]; then
        mspSubPath="$org.$DOMAIN"
        orgSubPath="peerOrganizations"
    else
        [ -n "$org" ] && mspSubPath="$org.$DOMAIN" orgSubPath="peerOrganizations" || mspSubPath="$DOMAIN" orgSubPath="ordererOrganizations"
    fi
    runCLI "wget ${WGET_OPTS} --directory-prefix crypto-config/${orgSubPath}/${mspSubPath}/msp/admincerts http://www.${mspSubPath}/msp/admincerts/Admin@${mspSubPath}-cert.pem"
    runCLI "wget ${WGET_OPTS} --directory-prefix crypto-config/${orgSubPath}/${mspSubPath}/msp/cacerts http://www.${mspSubPath}/msp/cacerts/ca.${mspSubPath}-cert.pem"
    runCLI "wget ${WGET_OPTS} --directory-prefix crypto-config/${orgSubPath}/${mspSubPath}/msp/tlscacerts http://www.${mspSubPath}/msp/tlscacerts/tlsca.${mspSubPath}-cert.pem"
    [ -z "$EXECUTE_BY_ORDERER" ] && runCLI "mkdir -p crypto-config/${orgSubPath}/${mspSubPath}/msp/tls/ \
    && cp crypto-config/${orgSubPath}/${mspSubPath}/msp/tlscacerts/tlsca.${mspSubPath}-cert.pem crypto-config/${orgSubPath}/${mspSubPath}/msp/tls/ca.crt"
}

function certificationsToEnv() {
    org=$1
    echo "export ORG_ADMIN_CERT=\`cat crypto-config/peerOrganizations/${org}.${DOMAIN:-example.com}/msp/admincerts/Admin@${org}.${DOMAIN:-example.com}-cert.pem | base64 -w 0\` \
      && export ORG_ROOT_CERT=\`cat crypto-config/peerOrganizations/${org}.${DOMAIN:-example.com}/msp/cacerts/ca.${org}.${DOMAIN:-example.com}-cert.pem | base64 -w 0\` \
      && export ORG_TLS_ROOT_CERT=\`cat crypto-config/peerOrganizations/${org}.${DOMAIN:-example.com}/msp/tlscacerts/tlsca.${org}.${DOMAIN:-example.com}-cert.pem | base64 -w 0\`"
}

function fetchChannelConfigBlock() {
    channel=${1:?"Channel name must be specified"}
    blockNum=${2:-config}
    runCLI "mkdir -p crypto-config/configtx && peer channel fetch $blockNum crypto-config/configtx/${channel}.pb -o orderer.$DOMAIN:7050 -c ${channel}  \
     ${ORDERER_TLSCA_CERT_OPTS} && chown -R $UID crypto-config/"
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

    envSubst "${templateFileOfUpdate}" "crypto-config/configtx/new_config_${org}.json" "$exportEnvironment"
    runCLI " jq -s '.[0] * {\"channel_group\":{\"groups\":.[1]}}' crypto-config/configtx/config.json crypto-config/configtx/new_config_${org}.json > crypto-config/configtx/updated_config.json"
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
    runCLI "peer channel update -f update_in_envelope.pb -c $channel -o orderer.$DOMAIN:7050 ${ORDERER_TLSCA_CERT_OPTS}"
}

function updateChannelConfig() {
    channel=${1:?Channel to be updated must be specified}
    org=${2:?Org to be updated must be specified}
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

    exportEnv="export CONSORTIUM_NAME=${consortiumName} && $(certificationsToEnv $org)"
    updateChannelConfig $channel $org ./templates/Consortium.json "$exportEnv"
}

function updateChannelModificationPolicy() {
    channel=${1:?"Channel must be specified"}
    updateChannelConfig $channel $ORG ./templates/ModPolicyOrgOnly.json
}

function addOrgToChannel() {
    channel=${1:?"Channel must be specified"}
    org=${2:?"New Org must be specified"}

    echo " >> Add new org '$org' to channel $channel"
    updateChannelConfig $channel $org ./templates/NewOrg.json "$(certificationsToEnv $org)"
}

function joinChannel() {
    channel=${1:?Channel name must be specified}

    echo "Join $ORG to channel $channel"
    fetchChannelConfigBlock $channel "0"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer channel join -b crypto-config/configtx/$channel.pb"
}

function updateAnchorPeers() {
    channel=${1:?Channel name must be specified}
    updateChannelConfig $channel $ORG ./templates/AnchorPeers.json
}


function installChaincode() {
    chaincodeName=${1:?Chaincode name must be specified}
    chaincodePath=${2:-$chaincodeName}
    lang=${3:-golang}
    chaincodeVersion=${4:-1.0}

    echo "Install chaincode $chaincodeName  $path $lang $version"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode install -n $chaincodeName -v $chaincodeVersion -p $chaincodePath -l $lang"
}

function installChaincodePackage() {
    chaincodeName=${1:?Chaincode package must be specified}

    echo "Install chaincode package $chaincodeName"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode install $chaincodeName"
}

function createChaincodePackage() {
    chaincodeName=${1:?Chaincode name must be specified}
    chaincodePath=${2:?Chaincode path must be specified}
    chaincodeLang=${3:?Chaincode lang must be specified}
    chaincodeVersion=${4:?Chaincode version must be specified}
    chaincodePackageName=${5:?Chaincode PackageName must be specified}

    echo "Packaging chaincode $chaincodePath to $chaincodeName"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode package -n $chaincodeName -v $chaincodeVersion -p $chaincodePath -l $chaincodeLang $chaincodePackageName"
}

function instantiateChaincode() {
    channelName=${1:?Channel name must be specified}
    chaincodeName=${2:?Chaincode name must be specified}
    initArguments=${3:-[]}
    chaincodeVersion=${4:-1.0}
    privateCollectionPath=${5}
    endorsementPolicy=${6}

    if  [ "$privateCollectionPath" == "\"\"" ] || [ "$privateCollectionPath" == "''" ]; then privateCollectionPath="" ; fi
    [ -n "$privateCollectionPath" ] && privateCollectionParam=" --collections-config /opt/chaincode/${privateCollectionPath}"

    [ -n "$endorsementPolicy" ] && endorsementPolicyParam=" -P \"${endorsementPolicy}\""

    arguments="{\"Args\":$initArguments}"
    echo "Instantiate chaincode $channelName $chaincodeName '$initArguments' $chaincodeVersion $privateCollectionPath $endorsementPolicy"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode instantiate -n $chaincodeName -v ${chaincodeVersion} -c '$arguments' -o orderer.$DOMAIN:7050 -C $channelName ${ORDERER_TLSCA_CERT_OPTS} $privateCollectionParam $endorsementPolicyParam"
}


function upgradeChaincode() {
    channelName=${1:?Channel name must be specified}
    chaincodeName=${2:?Chaincode name must be specified}
    initArguments=${3:-[]}
    chaincodeVersion=${4:-1.0}
    policy=${5}
    if [ -n "$policy" ]; then
        policy="-P \"$policy\"";
    fi

    arguments="{\"Args\":$initArguments}"

    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode upgrade -n $chaincodeName -v $chaincodeVersion -c '$arguments' -o orderer.$DOMAIN:7050 -C $channelName '$policy' ${ORDERER_TLSCA_CERT_OPTS}"
}

function callChaincode() {
    channelName=${1:?Channel name must be specified}
    chaincodeName=${2:?Chaincode name must be specified}
    arguments=${3:-[]}
    arguments="{\"Args\":$arguments}"
    action=${4:-query}
	echo "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode $action -n $chaincodeName -C $channelName -c '$arguments'"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode $action -n $chaincodeName -C $channelName -c '$arguments' ${ORDERER_TLSCA_CERT_OPTS}"
}

function queryChaincode() {
    channelName=${1:?Channel name must be specified}
    chaincodeName=${2:?Chaincode name must be specified}
    arguments=${3:-[]}
    arguments="{\"Args\":$arguments}"
    action=${4:-query}
	echo "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode query -n $chaincodeName -C $channelName -c '$arguments'"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode query -n $chaincodeName -C $channelName -c '$arguments' ${ORDERER_TLSCA_CERT_OPTS}"
}

function invokeChaincode() {
    channelName=${1:?Channel name must be specified}
    chaincodeName=${2:?Chaincode name must be specified}
    arguments=${3:-[]}
    arguments="{\"Args\":$arguments}"
	echo "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode invoke -n $chaincodeName -C $channelName -c '$arguments'"
    runCLI "CORE_PEER_ADDRESS=peer0.$ORG.$DOMAIN:7051 peer chaincode invoke -n $chaincodeName -C $channelName -c '$arguments' ${ORDERER_TLSCA_CERT_OPTS}"
}

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
#    read -n1 -r -p "Press any key to continue" key
#    echo
}

function parseOrganizationsForDockerMachine() {
    #   excpecting external variable is declared by: declare -a ORGS_MAP
    local orgsArg=${@:?List of organizations is expected}
    local orgs=()
    for orgMachineParam in $orgsArg; do
        local orgMachineArray=($(IFS=':'; echo ${orgMachineParam}))
        local org=${orgMachineArray[0]};
        orgs+=($org)
#        ORGS_MAP["$org"]="${orgMachineArray[1]}"
    done
    echo "${orgs[@]}"
    #  note: implicitly returning ORGS_MAP
}

function getHostOrgForOrg() {
    local org=${1:?Org name is expected}
    set +x
    for org_Machine in $ORGS_MAP; do
        local orgMachineArray=($(IFS=':'; echo ${org_Machine}))
        if [ "${org}" == "${orgMachineArray[0]}" ]; then
            echo ${orgMachineArray[1]}
        fi
    done
}

function getDockerMachineName() {
    local org=${1:?Org name is expected}
    local hostOrg=`getHostOrgForOrg $1`
    if [ -n "$hostOrg" ]; then
        local org=`getHostOrgForOrg $1`
    fi
    echo "$org.$DOMAIN"
}

function copyDirToMachine() {
    local machine=`getDockerMachineName $1`
    local src=$2
    local dest=$3

    info "Copying ${src} to remote machine ${machine}:${dest}"
    docker-machine ssh ${machine} sudo rm -rf ${dest}
#    docker-machine ssh ${machine} sudo mkdir -p ${dest}
    docker-machine scp -r ${src} ${machine}:${dest}
}

function copyFileToMachine() {
    local machine=`getDockerMachineName $1`
    local src=$2
    local dest=$3
    info "Copying ${src} to remote machine ${machine}:${dest}"
    docker-machine scp ${src} ${machine}:${dest}
}

function connectMachine() {
    local machine=`getDockerMachineName $1`

    info "Connecting to org $1 in remote machine $machine"
    eval "$(docker-machine env ${machine})"
    export ORG=${1}
}

function getMachineIp() {
    local machine=`getDockerMachineName $1`
    echo `(docker-machine ip ${machine})`
}

function setMachineWorkDir() {
    local machine=`getDockerMachineName $1`
    export WORK_DIR=`(docker-machine ssh ${machine} pwd)`
}

function createDirInMachine() {
    local machine=`getDockerMachineName $1`
    local dir=${2:?Specify directory to create}
    info "Create directory $dir on $machine"
    docker-machine ssh ${machine} mkdir -p "$dir"
}

function createHostsFileInOrg() {
    local org=${1:?Org must be specified}

    cp hosts org_hosts
    # remove entry of your own ip not to confuse docker and chaincode networking
    sed -i.bak "/.*\.$org\.$DOMAIN*/d" org_hosts
    orgs=`parseOrganizationsForDockerMachine ${ORGS_MAP}`

    local siblingOrg=`getHostOrgForOrg $org`
    if [ -n "$siblingOrg" ]; then
        sed -i.bak "/.*\.\?$siblingOrg\.$DOMAIN*/d" org_hosts
    fi
    for hostOrg in ${orgs}; do
        local siblingOrg=`getHostOrgForOrg $hostOrg`
        echo "Check $hostOrg:$siblingOrg"
        if [ "$siblingOrg" == "$org" ]; then
            echo "Exclude record from hosts for $hostOrg:$siblingOrg"
            sed -i.bak "/.*\.$hostOrg\.$DOMAIN*/d" org_hosts
            sed -i.bak "/.*\.\?$siblingOrg\.$DOMAIN*/d" org_hosts
        fi
    done

    createDirInMachine $org crypto-config
    copyFileToMachine ${org} org_hosts crypto-config/hosts_${org}
    rm org_hosts.bak org_hosts

    # you may want to keep this hosts file to append to your own local /etc/hosts to simplify name resolution
    # sudo cat hosts >> /etc/hosts
}

function createChannelAndAddOthers() {
    local c=$1

    connectMachine ${first_org}

    info "Creating channel $c by $ORG"
    ./channel-create.sh ${c}

    # First organization adds other organizations to the channel
    for org in ${orgs}
    do
        if [[ ${org} = ${first_org} ]]; then
            continue
        fi
        info "Adding $org to channel $c"
        ./channel-add-org.sh ${c} ${org}
    done

    # All organizations join the channel
    for org in ${orgs}
    do
        info "Joining $org to channel $c"
        connectMachine ${org}
        ./channel-join.sh ${c}
    done
}
