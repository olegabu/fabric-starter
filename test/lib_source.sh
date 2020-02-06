#!/usr/bin/env bash

#Assuming local Fabric installation



BASEDIR=$(dirname $0)

ls -la ./lib_util.sh
source ./lib_util.sh


START_DIR=$(pwd)

ORG=${ORG:-org1}
ORG1=${ORG}
ORG2=${ORG2:-org2}


DOMAIN=${DOMAIN:-example.com}
PEER_NAME=${PEER_NAME:-peer0}
API_NAME=${API_NAME:-api}

export TEST_TARGET='local'

function getAPIPort()
{
    api_n=$1
    org_n=$2
    domain_n=$3
    
    port=$(docker inspect ${api_n}.${org_n}.${domain_n} | jq -r '.[0].NetworkSettings.Ports | keys[] as $k | "\(.[$k]|.[0].HostPort)"')
    
    echo $port
}

function getAPIHost()
{
    api_n=$1
    org_n=$2
    domain_n=$3

    ipaddr=$(docker inspect ${api_n}.${org_n}.${domain_n} | jq -r '.[0].NetworkSettings.Ports | keys[] as $k | "\(.[$k]|.[0].HostIp)"')
    addr=$(echo $ipaddr | sed -e 's/0\.0\.0\.0/127.0.0.1/')

    echo $addr
}


function getPeer0Port()
{
    peer0_n=$1
    org_n=$2
    domain_n=$3
    
    port=$(docker inspect ${peer0_n}.${org_n}.${domain_n} | jq -r '.[0].NetworkSettings.Ports | keys[] as $k | "\(.[$k]|.[0].HostPort)"')
    echo $port
}


function getPeer0Host()
{
    peer0_n=$1
    org_n=$2
    domain_n=$3
    
    ipaddr=$(docker inspect ${peer0_n}.${org_n}.${domain_n} | jq -r '.[0].NetworkSettings.Ports | keys[] as $k | "\(.[$k]|.[0].HostIp)"')
    addr=$(echo $ipaddr | sed -e 's/0\.0\.0\.0/127.0.0.1/')
    
    echo $addr
}

getFabricStarterPath() {
    dirname=${1}
    libpath=$(realpath ${dirname}/lib.sh)
    
    if [[ ! -f ${libpath} ]]; then
        dirname=$(realpath ${dirname}/../)
        getFabricStarterPath ${dirname}
    else
        
        if [[ $dirname != '/' ]]; then
            echo ${dirname}
        else
            echo "Run tests in fabric-starter directory!"
            exit 1
        fi
    fi
}



export API1_PORT=$(getAPIPort "${API_NAME}" "${ORG1}" "${DOMAIN}")
export API2_PORT=$(getAPIPort "${API_NAME}" "${ORG2}" "${DOMAIN}")

export API1_HOST=$(getAPIHost "${API_NAME}" "${ORG1}" "${DOMAIN}")
export API2_HOST=$(getAPIHost "${API_NAME}" "${ORG2}" "${DOMAIN}")

export PEER1_PORT=$(getPeer0Port "${PEER_NAME}" "${ORG1}" "${DOMAIN}")
export PEER2_PORT=$(getPeer0Port "${PEER_NAME}" "${ORG2}" "${DOMAIN}")

export PEER1_HOST=$(getPeer0Host "${PEER_NAME}" "${ORG1}" "${DOMAIN}")
export PEER2_HOST=$(getPeer0Host "${PEER_NAME}" "${ORG2}" "${DOMAIN}")

export DOMAIN


#Exporting current Fabric Starter dir
FOUND_FABRIC_DIR=$(getFabricStarterPath ${START_DIR})
export FABRIC_DIR=${FABRIC_DIR:-"${FOUND_FABRIC_DIR}"}

cd ${FABRIC_DIR} && ls -la ./lib/util/util.sh && ls -la ./lib.sh &&  source ./lib/util/util.sh && source ./lib.sh
cd ${START_DIR}


#Setting debug log file path
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${BASEDIR}/fs_network_test.log"}}
[ ! -f ${FSTEST_LOG_FILE} ] || mv ${FSTEST_LOG_FILE} ${FSTEST_LOG_FILE}.prev
export FSTEST_LOG_FILE

export TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME:-'testlocal'$RANDOM}
#printDbg "Random channel name = $TEST_CHANNEL_NAME"

export CHAINCODE_PREFIX=${CHAINCODE_PREFIX:-reference}
export CHAINCODE_NAME=${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}




echo "API org1: ${API1_HOST}:${API1_PORT}"
echo "API org2: ${API2_HOST}:${API2_PORT}"

echo "PEER org1: ${PEER1_HOST}:${PEER1_PORT}"
echo "PEER org2: ${PEER2_HOST}:${PEER2_PORT}"

echo ${FSTEST_LOG_FILE}
echo ${FABRIC_DIR}
echo ${TEST_CHANNEL_NAME}