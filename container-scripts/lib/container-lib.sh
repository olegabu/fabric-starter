#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && LIBDIR=$(dirname ${BASH_SOURCE[0]}) || [ -n $BASH_SOURCE ] && LIBDIR=$(dirname ${BASH_SOURCE[0]}) || LIBDIR=$(dirname $0) #extract script's dir

source ${LIBDIR}/container-util.sh
source ./container-util.sh 2>/dev/null # IDE autocompletion

FABRIC_MAJOR_VERSION=${FABRIC_VERSION%%.*}
FABRIC_MAJOR_VERSION=${FABRIC_MAJOR_VERSION:-1}

source ${LIBDIR}/${FABRIC_MAJOR_VERSION}x/version-specifics.sh

export VERSIONED_CHAINCODE_PATH='/opt/chaincode'
if [ ${FABRIC_MAJOR_VERSION} -ne 1 ]; then # temporary skip v1, while 1.x chaincodes are located in root
    export VERSIONED_CHAINCODE_PATH="/opt/chaincode/${FABRIC_MAJOR_VERSION}x"
fi

: ${DOMAIN:="example.com"}
: ${ORG:="org1"}
: ${PEER_NAME:="peer0"}
: ${ORDERER_NAME:="orderer"}
: ${ORDERER_NAME_PREFIX:="raft"}
: ${ORDERER_DOMAIN:=${DOMAIN:-example.com}}
: ${INTERNAL_DOMAIN:=${DOMAIN:-example.com}}
: ${ORDERER_GENERAL_LISTENPORT:="7050"}
: ${SYSTEM_CHANNEL_ID:=orderer-system-channel}
: ${PEER0_PORT:=7051}
: ${RAFT0_CONSENTER_PORT:=7050}
: ${RAFT1_CONSENTER_PORT:=7150}
: ${RAFT2_CONSENTER_PORT:=7250}
: ${ORDERER_BATCH_TIMEOUT:=5}

: ${WGET_OPTS:=}
set -x
: ${WGET_CMD:= wget --verbose -N --directory-prefix}
export GENERATE_DIR=${TMP_DIR:-crypto-config}
set +x

: ${BASE64_UNWRAP_CODE:=-w 0} # "-b 0" for MacOs

if [ `uname` == 'Darwin' ]; then
    export BASE64_WRAP_OPT='-b' # debug on MacOs
else
    export BASE64_WRAP_OPT='-w'
fi

export ORG DOMAIN SYSTEM_CHANNEL_ID ORDERER_DOMAIN ORDERER_BATCH_TIMEOUT
#: ${ORDERER_GENERAL_TLS_ROOTCERT_FILE="/etc/hyperledger/crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/orderers/${ORDERER_NAME}.${ORDERER_DOMAIN}/tls/ca.crt"}
: ${ORDERER_GENERAL_TLS_ROOTCERT_FILE="/etc/hyperledger/crypto-config/ordererOrganizations/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${ORDERER_DOMAIN}-cert.pem"}
: ${ORDERER_TLSCA_CERT_OPTS="--tls --cafile ${ORDERER_GENERAL_TLS_ROOTCERT_FILE}"}
: ${ORDERER_ADDRESS="${ORDERER_NAME}.${INTERNAL_DOMAIN:-$ORDERER_DOMAIN}:${ORDERER_GENERAL_LISTENPORT}"}

function downloadOrdererMSP() {
    local remoteOrdererName=${1:?-Orderer name is required}
    local remoteOrdererDOMAIN=${2:-${ORDERER_DOMAIN}}
    local wwwPort=${3:-80}

    local mspSubPath="$remoteOrdererDOMAIN"
#    local serverDNSName=${remoteOrdererName}.${remoteOrdererDOMAIN}:${wwwPort}
    local serverDNSName=${remoteOrdererDOMAIN}:${wwwPort}
    downloadMSP "ordererOrganizations" "${serverDNSName}" "${remoteOrdererDOMAIN}" "${remoteOrdererName}.${remoteOrdererDOMAIN}"
#    wget ${WGET_OPTS} --directory-prefix crypto-config/ordererOrganizations/${mspSubPath}/msp/${remoteOrdererName}.${remoteOrdererDOMAIN}/tls http://www.${serverDNSName}/msp/${remoteOrdererName}.${remoteOrdererDOMAIN}/tls/server.crt
    ${WGET_CMD} crypto-config/ordererOrganizations/${mspSubPath}/msp/${remoteOrdererName}.${remoteOrdererDOMAIN}/tls http://www.${serverDNSName}/node-certs/${rdemoteOrdererName}.${remoteOrdererDOMAIN}/tls/server.crt
}

function downloadOrgMSP() {
    local org=${1:?Org is required}
    local wwwPort=${2:-80}
    local domain=${3:-$DOMAIN}
    downloadMSP "peerOrganizations" "${org}.${domain}:${wwwPort}" "${org}.${domain}"
}

function downloadMSP() {
    local typeSubPath=$1
    local wwwServerAddress=$2
    local mspSubPath=$3
    local urlSubPath=${4:-$mspSubPath}

    local serverDNSName=www.${wwwServerAddress:-${mspSubPath}}
    mkdir -p crypto-config/${typeSubPath}/${mspSubPath}/msp/admincerts
    mkdir -p crypto-config/${typeSubPath}/${mspSubPath}/msp/cacerts
    mkdir -p crypto-config/${typeSubPath}/${mspSubPath}/msp/tlscacerts
    set -x
    ${WGET_CMD} crypto-config/${typeSubPath}/${mspSubPath}/msp/admincerts http://${serverDNSName}/node-certs/${urlSubPath}/msp/admincerts/Admin@${mspSubPath}-cert.pem
    ${WGET_CMD} crypto-config/${typeSubPath}/${mspSubPath}/msp/cacerts http://${serverDNSName}/node-certs/${urlSubPath}/msp/cacerts/ca.${mspSubPath}-cert.pem
    ${WGET_CMD} crypto-config/${typeSubPath}/${mspSubPath}/msp/tlscacerts http://${serverDNSName}/node-certs/${urlSubPath}/msp/tlscacerts/tlsca.${mspSubPath}-cert.pem
    set +x
}

function certificationsToEnv() { # TODO: consider sourcedir and orderer name in all calls
    local org=${1:?Org is required}
    local domain=${2:-${DOMAIN}}
    local certsSourceDir=${3:-crypto-config}
    local ordererName=${4}

    echo "Put certs to env for ${ordererName:-$org}.$domain"
    local mspDir="${certsSourceDir}/peerOrganizations/${org}.${domain}/msp"
    if [ -n "${ordererName}" ]; then
        mspDir="${certsSourceDir}/ordererOrganizations/${domain}/msp";
        org=""
    fi
    export ORG_ADMIN_CERT=`eval "cat ${mspDir}/admincerts/Admin@${org}${org:+.}${domain}-cert.pem | base64 ${BASE64_UNWRAP_CODE}"` \
      && export ORG_ROOT_CERT=`eval "cat ${mspDir}/cacerts/ca.${org}${org:+.}${domain}-cert.pem | base64 ${BASE64_UNWRAP_CODE}"` \
      && export ORG_TLS_ROOT_CERT=`eval "cat ${mspDir}/tlscacerts/tlsca.${org}${org:+.}${domain}-cert.pem | base64 ${BASE64_UNWRAP_CODE}"`
}

function ordererCertificationsToEnv() {
    local mspDir="crypto-config/ordererOrganizations/${DOMAIN}/msp";
    export ORG_ADMIN_CERT=`eval "cat ${mspDir}/admincerts/Admin@${org}${org:+.}${DOMAIN:-example.com}-cert.pem | base64 ${BASE64_UNWRAP_CODE}"` \
      && export ORG_ROOT_CERT=`eval "cat ${mspDir}/cacerts/ca.${org}${org:+.}${DOMAIN:-example.com}-cert.pem | base64 ${BASE64_UNWRAP_CODE}"` \
      && export ORG_TLS_ROOT_CERT=`eval "cat ${mspDir}/tlscacerts/tlsca.${org}${org:+.}${DOMAIN:-example.com}-cert.pem | base64 ${BASE64_UNWRAP_CODE}"`
}

function fetchChannelConfigBlock() {
    local channel=${1:?"Channel name must be specified"}
    local blockNum=${2:-config}
    local outputFile=${3:-${GENERATE_DIR}/configtx/${channel}.pb}

    mkdir -p ${GENERATE_DIR}/configtx
    echo "Execute: channel fetch $blockNum ${outputFile} -o ${ORDERER_ADDRESS} -c ${channel} ${ORDERER_TLSCA_CERT_OPTS}"
    peer channel fetch $blockNum ${outputFile} -o ${ORDERER_ADDRESS} -c ${channel} ${ORDERER_TLSCA_CERT_OPTS}
    sleep 1
}

function txTranslateChannelConfigBlock() {
    local channel=$1
    local outputFile=${2:-${GENERATE_DIR}/configtx/config.json}
    rm -f ${GENERATE_DIR}/configtx/${channel}.pb ${GENERATE_DIR}/configtx/${channel}.json ${outputFile}
    fetchChannelConfigBlock $channel
    configtxlator proto_decode --type 'common.Block' --input=${GENERATE_DIR}/configtx/${channel}.pb --output=${GENERATE_DIR}/configtx/${channel}.json
    jq .data.data[0].payload.data.config ${GENERATE_DIR}/configtx/${channel}.json > ${outputFile}
}

function updateChannelGroupConfigForOrg() {
    local org=${1:?Org is required}
    local templateFileOfUpdate=${2:?Template file is required}
    local newOrgAnchorPeerPort=${3:-7051}
    local outputFile=${4:-${GENERATE_DIR}/configtx/updated_config.json}

    export NEWORG=${org} NEWORG_PEER0_PORT=${newOrgAnchorPeerPort}
    echo "Prepare updated config ${GENERATE_DIR}/configtx/new_config_${org}.json"
    envsubst < "${templateFileOfUpdate}" > "${GENERATE_DIR}/configtx/new_config_${org}.json"
    jq -s '.[0] * {"channel_group":{"groups":.[1]}}' ${GENERATE_DIR}/configtx/config.json ${GENERATE_DIR}/configtx/new_config_${org}.json > "${outputFile}"
}

function mergeListsInJsons() {
    local firstFile=${1:?First file is required}
    local firstFileJsonPath=${2:?Json path in first file is required}
    local secondFile=${3:?Second file is required}
    local secondFileJsonPath=${4:?Json path in second file is required}
    local outputFile=${5:?Output file is requried}
    sh -c "jq -s '.[1][\"${secondFileJsonPath}\"] as \$newItems | .[0].${firstFileJsonPath} |= .+\$newItems | .[0]' $firstFile $secondFile  > ${outputFile}.temp"
    local res=$?
    [ $res -ne 0 ] && return $res
    mv ${outputFile}.temp ${outputFile}
}

function removeFromListInJson() {
    local file=${1:?File is required}
    local pathToArray=${2:?Json path to array is required}
    local filter=${3:?Filter is required}
    local outputFile=${4:?Output file is requried}
    sh -c "jq -s '.[0].${pathToArray} |= map(${filter}) | .[0]' $file > ${outputFile}.temp"
    local res=$?
    [ $res -ne 0 ] && return $res
    mv ${outputFile}.temp ${outputFile}
}

function createConfigUpdateEnvelope() {
    local channel=$1
    local configJson=${2:-"${GENERATE_DIR}/configtx/config.json"}
    local updatedConfigJson=${3:-"${GENERATE_DIR}/configtx/updated_config.json"}

    difference=`diff ${configJson} ${updatedConfigJson}`
    if [ -z "$difference" ]; then
        echo -e "\n No difference in configs. Skipping update config block.\n"
        exit 0
    fi
    echo " >> Prepare config update from $org for channel $channel"
    configtxlator proto_encode --type 'common.Config' --input=${configJson} --output=${GENERATE_DIR}/config.pb \
    && configtxlator proto_encode --type 'common.Config' --input=${updatedConfigJson} --output=${GENERATE_DIR}/updated_config.pb \
    && configtxlator compute_update --channel_id=$channel --original=${GENERATE_DIR}/config.pb  --updated=${GENERATE_DIR}/updated_config.pb --output=${GENERATE_DIR}/update.pb \
    && configtxlator proto_decode --type 'common.ConfigUpdate' --input=${GENERATE_DIR}/update.pb --output=${GENERATE_DIR}/configtx/update.json && chown $UID ${GENERATE_DIR}/configtx/update.json

    echo "{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"$channel\",\"type\":2}},\"data\":{\"config_update\":`cat ${GENERATE_DIR}/configtx/update.json`}}}" | jq . > ${GENERATE_DIR}/configtx/update_in_envelope.json
    configtxlator proto_encode --type 'common.Envelope' --input=${GENERATE_DIR}/configtx/update_in_envelope.json --output=${GENERATE_DIR}/update_in_envelope.pb
    echo " >> $org is sending channel update update_in_envelope.pb with $d by $command"
    echo "Execute: peer channel update -f update_in_envelope.pb -c ${channel} -o ${ORDERER_ADDRESS} ${ORDERER_TLSCA_CERT_OPTS}"
    peer channel update -f ${GENERATE_DIR}/update_in_envelope.pb -c ${channel} -o ${ORDERER_ADDRESS} ${ORDERER_TLSCA_CERT_OPTS}
}



function insertObjectIntoChannelConfig() {
    local channel=${1:?Channel is required}
    local org=${2:?Org is required}
    local templateFile=${3:?Template is required}
    local peer0Port=${4}
    local outputFile=${5:-${GENERATE_DIR}/configtx/updated_config.json}

    echo "$org is updating channel $channel config with $templateFile, peer0Port: $peer0Port outputFile: $outputFile"
    txTranslateChannelConfigBlock "$channel"
    updateChannelGroupConfigForOrg "$org" "$templateFile" $peer0Port $outputFile
}


function updateChannelConfig() {
    local channel=${1:?Channel is required}
    local org=${2:?Org is required}
    local templateFile=${3:?Template is required}
    local anchorPort=${4}
    local domain=${5:-$DOMAIN}
    certificationsToEnv $org $domain
    insertObjectIntoChannelConfig $@
    createConfigUpdateEnvelope $channel
}


function mergeListIntoChannelConfig() {
    local channel=${1:?Channel is requried}
    local configInputFile=${2:?Config input file is requried}
    local configJsonPath=$3
    local mergedFile=$4
    local mergedFileJsonPath=$5
    local outputFile=${6:-${GENERATE_DIR}/configtx/updated_config.json}
    mergeListsInJsons ${configInputFile} ${configJsonPath} ${mergedFile} ${mergedFileJsonPath} ${outputFile}
}

function removeObjectFromChannelConfig() {
    local channel=${1:?Channel is requried}
    local configInputFile=${2:?Config input file is requried}
    local configJsonPath=$3
    local outputFile=${4:-${GENERATE_DIR}/configtx/updated_config.json}
    sh -c "jq 'del (.${configJsonPath})' $configInputFile > ${outputFile}.temp "
    mv ${outputFile}.temp ${outputFile}
}


function updateConsortium() {
    local org=${1:?Org to be added to consortium must be specified}
    local channel=${2:?System channel must be specified}
    local domain=${3:-$DOMAIN}
    local updateTemplateFile=${4:-./templates/Consortium.json}
    local consortiumName=${5:-SampleConsortium}
    export CONSORTIUM_NAME=${consortiumName}
    certificationsToEnv $org $domain
    updateChannelConfig $channel $org "$updateTemplateFile"
}

function updateAnchorPeers() {
    local org=${1:?Org to be configured must be specified}
    local channel=${2:?Channel name must be specified}
    updateChannelConfig $channel $org ./templates/AnchorPeers.json
}

function createChannel() {
    local channelName=${1:?Channel name must be specified}
    printYellow "\nCreate channel $ORG $channelName\n"
#    downloadOrdererMSP ${ORDERER_NAME} ${ORDERER_DOMAIN} #${ORDERER_WWW_PORT}
    set -x
    mkdir -p ${GENERATE_DIR}/configtx
    envsubst < "templates/configtx-template.yaml" > "${GENERATE_DIR}/configtx.yaml"
    cat ${GENERATE_DIR}/configtx.yaml

    printYellow "\n configtxgen \n"
    configtxgen -configPath ${GENERATE_DIR}/ -outputCreateChannelTx ${GENERATE_DIR}/configtx/channel_$channelName.tx -profile CHANNEL -channelID $channelName
    printYellow "\n peer channel create \n"
    peer channel create -o ${ORDERER_ADDRESS} -c $channelName -f ${GENERATE_DIR}/configtx/channel_$channelName.tx ${ORDERER_TLSCA_CERT_OPTS}
    set +x
    updateAnchorPeers "$ORG" "$channelName"

}

function addOrgToChannel() {
    local channel=${1:?"Channel is required"}
    local org=${2:?"New Org is required"}
    local newOrgAnchorPeerPort=${3}
    local newOrgDomain=${4:-$DOMAIN}

    echo " >> Add new org '$org' to channel $channel, anchor peer at port $newOrgAnchorPeerPort"
    certificationsToEnv $org $newOrgDomain
    updateChannelConfig $channel $org ./templates/NewOrg.json $newOrgAnchorPeerPort $newOrgDomain
}

function joinChannel() {
    local channel=${1:?Channel name must be specified}

    echo "Join $ORG to channel $channel"
    fetchChannelConfigBlock $channel "0"
    CORE_PEER_ADDRESS=$PEER_NAME-$ORG.$DOMAIN:$PEER0_PORT peer channel join -b ${GENERATE_DIR}/configtx/$channel.pb
}

function createChaincodePackage() {
    local chaincodeName=${1:?Chaincode name must be specified}
    local chaincodePath=${2:?Chaincode path must be specified}
    local chaincodeLang=${3:?Chaincode lang must be specified}
    local chaincodeVersion=${4:?Chaincode version must be specified}
    local chaincodePackageName=${5:?Chaincode PackageName must be specified}

    echo "Packaging chaincode $chaincodePath to $chaincodeName"
    CORE_PEER_ADDRESS=$PEER_NAME-$ORG.$DOMAIN:$PEER0_PORT peer chaincode package -n $chaincodeName -v $chaincodeVersion -p $chaincodePath -l $chaincodeLang $chaincodePackageName
}

#function installChaincodePackage() {
#    local chaincodeName=${1:?Chaincode package must be specified}
#
#    echo "Install chaincode package $chaincodeName"
#    CORE_PEER_ADDRESS=$PEER_NAME.$ORG.$DOMAIN:$PEER0_PORT peer chaincode install $chaincodeName
#}

#function installChaincode {
#    local chaincodeName=${1:?Chaincode name must be specified}
#    local chaincodePath=${2:-$chaincodeName}
#    local lang=${3:-golang}
#    local chaincodeVersion=${4:-1.0}
#
#    echo "Install chaincode $chaincodeName  $chaincodePath $lang $chaincodeVersion"
#    CORE_PEER_ADDRESS=$PEER_NAME.$ORG.$DOMAIN:$PEER0_PORT peer chaincode install -n $chaincodeName -v $chaincodeVersion -p $chaincodePath -l $lang
#}

#function initChaincode() {
#    local operation=${1:?Operation is required}
#    local channelName=${2:?Channel is required}
#    local chaincodeName=${3:?Chaincode is required}
#    local initArguments=${4:-[]}
#    local chaincodeVersion=${5:-1.0}
#    local privateCollectionPath=${6}
#    local endorsementPolicy=${7}
#    local arguments="{\"Args\":$initArguments}"
#
#    if  [ "$privateCollectionPath" == "\"\"" ] || [ "$privateCollectionPath" == "''" ]; then privateCollectionPath="" ; fi
#    [ -n "$privateCollectionPath" ] && privateCollectionParam=" --collections-config /opt/chaincode/${privateCollectionPath}"
#
#    [ -n "$endorsementPolicy" ] && endorsementPolicyParam=" -P \"${endorsementPolicy}\""
#
#    echo "Instantiate chaincode $channelName $chaincodeName '$initArguments' $chaincodeVersion $privateCollectionPath $endorsementPolicy"
#    CORE_PEER_ADDRESS=$PEER_NAME.$ORG.$DOMAIN:$PEER0_PORT peer chaincode ${operation} -n $chaincodeName -v ${chaincodeVersion} -c "${arguments}" -o ${ORDERER_ADDRESS} -C $channelName ${ORDERER_TLSCA_CERT_OPTS} $privateCollectionParam $endorsementPolicyParam
#}

function instantiateChaincode() {
    local channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
    local chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
    local initArguments=${3}
    local chaincodeVersion=${4-1.0}
    local privateCollectionPath=${5}
    local endorsementPolicy=${6}
    initChaincode instantiate "$channelName" "$chaincodeName" "$initArguments" "$chaincodeVersion" "$privateCollectionPath" "$endorsementPolicy"
}

function upgradeChaincode() {
    initChaincode upgrade $@
}

function callChaincode() {
    local channelName=${1:?Channel name must be specified}
    local chaincodeName=${2:?Chaincode name must be specified}
    local arguments=${3:-[]}
    local arguments="{\"Args\":$arguments}"
    local action=${4:-query}
    local peerPort=${5:-7051}
    local domain=${6:-${INTERNAL_DOMAIN:-$DOMAIN}}
    echo "CORE_PEER_ADDRESS=$PEER_NAME-$ORG.$domain:$PEER0_PORT peer chaincode $action -n $chaincodeName -C $channelName -c '$arguments' -o ${ORDERER_ADDRESS} ${ORDERER_TLSCA_CERT_OPTS}"
    CORE_PEER_ADDRESS=$PEER_NAME-$ORG.$domain:$PEER0_PORT peer chaincode $action -n $chaincodeName -C $channelName -c "$arguments" -o ${ORDERER_ADDRESS} ${ORDERER_TLSCA_CERT_OPTS}
}

function queryChaincode() {
    callChaincode "$1" "$2" "$3" query
}

function invokeChaincode() {
    callChaincode "$1" "$2" "$3" invoke
}
