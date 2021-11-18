function copyTestChiancodeCLI() {
    local channel=${1}
    local org=${2}
    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    
    local result
    local exitCode
    pushd ${FABRIC_DIR} > /dev/null
    
    result=$(ORG=${org} runCLI \
        "mkdir -p /opt/chaincode/node/${chaincode_init_name}_${channel} ;\
    cp -R /opt/chaincode/node/reference/* \
    /opt/chaincode/node/${chaincode_init_name}_${channel}")
    exitCode=$?
    printDbg "${result}"
    
    popd > /dev/null
    setExitCode [ "${exitCode}" = "0" ]
}


function installTestChiancodeCLI() {
    local channel=${1}
    local org=${2}
    local chaincode_name=$(getTestChaincodeName "${channel}")
    
    local exitCode
    
    pushd ${FABRIC_DIR} > /dev/null
    
    ORG=${org} runCLI "./container-scripts/network/chaincode-install.sh '${chaincode_name}'" 2>&1 | printDbg
    local exitCode=$?
    
    popd > /dev/null
    setExitCode [ "${exitCode}" = "0" ]
}

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

function verifyChiancodeInstalled() {
    local channel=${1}
    local org=${2}

    local chaincode_init_name
    local chaincode_name
    local result

    chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    chaincode_name=${chaincode_init_name}_${channel}
    result=$(ListPeerChaincodes ${channel} ${org} | grep Name | cut -d':' -f 2 | cut -d',' -f 1 | cut -d' ' -f 2 | grep -E "^${chaincode_name}$" )

    printDbg "${result}"
    
    setExitCode [ "${result}" = "${chaincode_name}" ]
}

