
function ListPeerChaincodes() {
    local channel=${1}
    local org2_=${2}
    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    
    local result
    local exitCode
    
    pushd ${FABRIC_DIR} > /dev/null
    
    result=$(runCLI "/opt/chaincode/node; peer chaincode list --installed -C '${channel}' -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS")
    exitCode=$?
    
    popd > /dev/null
    
    printDbg "${result}"
    
    set -f
    IFS=
    echo ${result}
    set +f
    
    setExitCode [ "${exitCode}" = "0" ]
}


function ListPeerChaincodesInstantiated() {
    local channel=${1}
    local org2_=${2}
    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    
    local result
    local exitCode
    
    pushd ${FABRIC_DIR} > /dev/null
    
    result=$(ORG=${org2_} runCLI "peer chaincode list --instantiated -C '${channel}' -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS")
    exitCode=$?
    
    popd > /dev/null
    
    printDbg "${result}"
    
    set -f
    IFS=
    echo ${result}
    set +f
    
    setExitCode [ "${exitCode}" = "0" ]
}

function getChaincodeListFromPeer() {
    local channel=${1}
    local org=${2}

    echo $(ListPeerChaincodes ${channel} ${org} | grep Name | cut -d':' -f 2 | cut -d',' -f 1 | cut -d' ' -f 2 | grep -E "^${chaincode_name}$" )
}
