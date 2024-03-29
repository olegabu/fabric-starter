#####
#  CLI functions specific for Hyperledger Fabric version 2.x
#####

function installChaincode {
    local chaincodeName=${1:?Chaincode name must be specified}
    local chaincodePath=${2:-$chaincodeName}
    local lang=${3:-golang}
    local chaincodeVersion=${4:-1.0}

    echo "Install chaincode 2.x $chaincodeName  $chaincodePath $lang $chaincodeVersion"

    local CC_LABEL=${chaincodeName}_${chaincodeVersion}
    set -x
    peer lifecycle chaincode package ${chaincodeName}.tar.gz --path $chaincodePath --lang $lang --label $CC_LABEL
    set +x
    sleep 1
    installChaincodePackage "${chaincodeName}.tar.gz"
}

function installChaincodePackage() {
    local chaincodePackage=${1:?Chaincode package must be specified}

    echo "Install chaincode package $chaincodePackage"
    peer lifecycle chaincode install "${chaincodePackage}"
}

function initChaincode() {
    local operation=${1:?Operation is required}
    local channelName=${2:?Channel is required}
    local chaincodeName=${3:?Chaincode is required}
    local initArguments=${4}
    local chaincodeVersion=${5:-1.0}
    local privateCollectionPath=${6}
    local endorsementPolicy=${7}

    approveChaincode ${channelName} ${chaincodeName} ${chaincodeVersion} ${initArguments}
    commitChaincode ${channelName} ${chaincodeName} ${chaincodeVersion} "${privateCollectionPath}" "${endorsementPolicy}"
}

function approveChaincode() {
    local channelName=${1:?Channel is required}
    local chaincodeName=${2:?Chaincode is required}
    local chaincodeVersion=${3:-1.0}
    local initArguments=${4}

    local CC_LABEL=${chaincodeName}_${chaincodeVersion}
    local CC_PACKAGE_ID=`peer lifecycle chaincode queryinstalled | grep $CC_LABEL`
    CC_PACKAGE_ID=${CC_PACKAGE_ID#*: }
    CC_PACKAGE_ID=${CC_PACKAGE_ID%,*}
    printYellow  "\n Approving chaincode: $CC_PACKAGE_ID \n"

    set -x
    local SEQUENCE=`peer lifecycle chaincode queryapproved --channelID ${channelName} --name ${chaincodeName} 2>/dev/null | grep "$CC_PACKAGE_ID"`
    set +x
    if [[ -n "${SEQUENCE}" ]]; then
        SEQUENCE=`substring "${SEQUENCE}" 'sequence: ' ',*'`
    fi
    SEQUENCE=$((SEQUENCE+1))
    local initParam=${initArguments:+--init-required}
    set -x
    peer lifecycle chaincode approveformyorg -o ${ORDERER_ADDRESS}  --channelID ${channelName} --name ${chaincodeName} \
        --version ${chaincodeVersion} --package-id ${CC_PACKAGE_ID} --sequence ${SEQUENCE} ${ORDERER_TLSCA_CERT_OPTS} ${initParam}
    set +x
}

function commitChaincode() {
    local channelName=${1:?Channel is required}
    local chaincodeName=${2:?Chaincode is required}
    local chaincodeVersion=${3:-1.0}
    local privateCollectionPath=${4}
    local endorsementPolicy=${5}
    local initArguments=${6:-[]}
    local arguments="{\"Args\":$initArguments}"

    printYellow  "\n Committing chaincode: $chaincodeName_$chaincodeVersion on channel: $channelName \n"

    if  [ "$privateCollectionPath" == "\"\"" ] || [ "$privateCollectionPath" == "''" ]; then privateCollectionPath="" ; fi
    [ -n "$privateCollectionPath" ] && privateCollectionParam=" --collections-config ${privateCollectionPath}"

    [ -n "$endorsementPolicy" ] && endorsementPolicyParam=" --signature-policy \"${endorsementPolicy}\""

    set -x
    local SEQUENCE=`peer lifecycle chaincode querycommitted --channelID ${channelName} --name ${chaincodeName} 2>/dev/null | grep "Sequence:"`
    set +x
    if [[ -n "${SEQUENCE}" ]]; then
        SEQUENCE=`substring "${SEQUENCE}" '*Sequence: ' ',*'`
    fi
    SEQUENCE=$((SEQUENCE+1))

    local commitReady="${ORG}: false" count=10
    while [[  "$commitReady" = "${ORG}: false" && $count > 0 ]]; do
        sleep 1
        count=$((count - 1))
        set -x
        commitReady=`peer lifecycle chaincode checkcommitreadiness \
            --channelID ${channelName} --name ${chaincodeName} --version ${chaincodeVersion} \
            --sequence ${SEQUENCE} ${ORDERER_TLSCA_CERT_OPTS}`
        set +x
    done

    if [[ "$commitReady" = "${ORG}: false"  ]]; then
        printError "Commit readiness check not passed"
        exit 1
    fi
    set -x
    peer lifecycle chaincode commit -o ${ORDERER_ADDRESS} \
        --channelID ${channelName} --name ${chaincodeName} --version ${chaincodeVersion} \
        --sequence ${SEQUENCE} ${ORDERER_TLSCA_CERT_OPTS} \
        ${privateCollectionParam} ${endorsementPolicyParam}
    set +x
}


function substring() {
    local sourceString=${1:?Source string is required}
    local leftPattern=$2
    local rightPattern=$3
    sourceString=${sourceString#${leftPattern}}
    sourceString=${sourceString%%${rightPattern}}
    echo ${sourceString}
}
function listPackageIDsInstalled() {

    local result=$(peer lifecycle chaincode queryinstalled --output json)
    set -f
    IFS=
    echo "${result}"
    set +f
}

function listChaincodesInstalled() {
    local channel=${1}
    local org=${2}
    local result


    result=$(listPackageIDsInstalled)
    set -f
    IFS=
    echo "${result}" | jq -r '.[][].package_id' | cut -d ':' -f 1 | rev | cut -d '_' -f 2- | rev
    set +f
}


function listChaincodesInstantiated() {
    local channel=${1}
    local org=${2}
    local result


    #result=$(peer lifecycle chaincode querycommitted -C ${channel} -O json)
    result=$(peer lifecycle chaincode querycommitted -C ${channel} -O json)

    set -f
    IFS=
    echo "${result}"  | jq -r '.[][] | .name'
    set +f
}

function getChannelConfigJSON() {
    local channel=${1}
    local result
    result=$(peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS -c ${channel} $ORDERER_TLSCA_CERT_OPTS | configtxlator proto_decode --type "common.Block")
    echo "${result}"
}

function findChannelNameInConfig() {
    local channel=${1}
    local result
    result=$(getChannelConfigJSON $channel | jq -e -r '.data.data[0].payload.header.channel_header.channel_id // empty')
    exitCode=$?
    [[ ! -z "${result}" ]] && echo "${result}"
    return $exitCode
}

function findOrgNameInChannelConfig() {
    local channel=${1}
    local org=${2}
    local result
    result=$(getChannelConfigJSON $channel | jq -e -r ".data.data[0].payload.data.config.channel_group.groups.Application.groups.${org}.values.MSP.value.config.name // empty")
    exitCode=$?
    [[ ! -z "${result}" ]] && echo "${result}"
    return $exitCode
}
