#####
#  CLI functions specific for Hyperledger Fabric version 1.x
#####

function approveChaincode() {
    echo "Skip approve for ver 1"
}


function installChaincode {
    local chaincodeName=${1:?Chaincode name must be specified}
    local chaincodePath=${2:-$chaincodeName}
    local lang=${3:-golang}
    local chaincodeVersion=${4:-1.0}

    echo "Install chaincode $chaincodeName  $chaincodePath $lang $chaincodeVersion"
    CORE_PEER_ADDRESS=$PEER_NAME.$ORG.$DOMAIN:$PEER0_PORT peer chaincode install -n $chaincodeName -v $chaincodeVersion -p $chaincodePath -l $lang
}

function installChaincodePackage() {
    local chaincodeName=${1:?Chaincode package must be specified}

    echo "Install chaincode package $chaincodeName"
    CORE_PEER_ADDRESS=$PEER_NAME.$ORG.$DOMAIN:$PEER0_PORT peer chaincode install $chaincodeName
}


function initChaincode() {
    local operation=${1:?Operation is required}
    local channelName=${2:?Channel is required}
    local chaincodeName=${3:?Chaincode is required}
    local initArguments=${4:-[]}
    local chaincodeVersion=${5:-1.0}
    local privateCollectionPath=${6}
    local endorsementPolicy=${7}
    local arguments="{\"Args\":$initArguments}"

    if  [ "$privateCollectionPath" == "\"\"" ] || [ "$privateCollectionPath" == "''" ]; then privateCollectionPath="" ; fi
    [ -n "$privateCollectionPath" ] && privateCollectionParam=" --collections-config /opt/chaincode/${privateCollectionPath}"

    [ -n "$endorsementPolicy" ] && endorsementPolicyParam=" -P \"${endorsementPolicy}\""

    echo "Instantiate chaincode $channelName $chaincodeName '$initArguments' $chaincodeVersion $privateCollectionPath $endorsementPolicy"
    CORE_PEER_ADDRESS=$PEER_NAME.$ORG.$DOMAIN:$PEER0_PORT peer chaincode ${operation} -n $chaincodeName -v ${chaincodeVersion} -c "${arguments}" -o ${ORDERER_ADDRESS} -C $channelName ${ORDERER_TLSCA_CERT_OPTS} $privateCollectionParam $endorsementPolicyParam
}

