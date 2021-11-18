function copyTestChiancodeCLI() {
    local channel=${1}
    local org=${2}
    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    
    local result
    local exitCode
    pushd ${FABRIC_DIR} > /dev/null
    
    result=$(ORG=${org} runCLI \
        "mkdir -p /opt/chaincode/2x/node/${chaincode_init_name}_${channel} ;\
    cp -R /opt/chaincode/2x/node/reference/* \
    /opt/chaincode/2x/node/${chaincode_init_name}_${channel}")
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
    

    ORG=${org} runCLI "./container-scripts/network/chaincode-install.sh '${chaincode_name}' 1.0 /opt/chaincode/2x/node/${chaincode_name}" node 2>&1 | printDbg
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
    
    result=$(runCLI "peer lifecycle chaincode queryinstalled")
    exitCode=$?
    
    popd > /dev/null
    printDbg "${result}"
    set -f
    IFS=
    echo "${result}" | grep Label
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
    
    result=$(ORG=${org2_} runCLI "peer lifecycle chaincode querycommitted -C '${channel}'")
    exitCode=$?
    
    popd > /dev/null
    
    printDbg "${result}"
    
    set -f
    IFS=
    echo ${result}
    set +f
    
    setExitCode [ "${exitCode}" = "0" ]
}

function getChaincodeListFromPeer2x() {
    local channel=${1}
    local org=${2}

    echo $(ListPeerChaincodes ${channel} ${org}| grep Label | cut -d':' -f 2 | sed -e 's/\s//g' | grep -E "^${chaincode_name}_")
}

function cutChaincodeNameFromPeer2x() {
    local chaincode_string=${1}
    echo $chaincode_string | rev | cut -d '_' -f 2- | rev
}


function verifyChiancodeInstalled() {
    local channel=${1}
    local org=${2}

    local chaincode_init_name
    local chaincode_name
    local chaincode_list
    local result

    chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    chaincode_name=${chaincode_init_name}_${channel}
    chaincode_list=$(getChaincodeListFromPeer2x $channel $org)
    result=$(cutChaincodeNameFromPeer2x $chaincode_list)
    printDbg "Result: ${result}"
    
    setExitCode [ "${result}" = "${chaincode_name}" ]
}

