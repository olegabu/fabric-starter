
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

function getChaincodeListFromPeer() {
    local channel=${1}
    local org=${2}

    echo $(ListPeerChaincodes ${channel} ${org}| grep Label | cut -d':' -f 2 | sed -e 's/\s//g' | grep -E "^${chaincode_name}_" | rev | cut -d '_' -f 2- | rev)
}
