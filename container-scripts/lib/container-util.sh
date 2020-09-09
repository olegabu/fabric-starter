#!/usr/bin/env bash


function printInColor() {
    color1=$1
    message1=$2
    color2=$3
    message2=$4
    echo -e "\033[${color1}m${message1}\033[m\033[${color2}m$message2\033[m"
}

function printError() {
    printInColor "1;31" "$1"
}

function printGreen() {
    printInColor "1;32" "$1"
}

function printYellow() {
    printInColor "1;33" "$1"
}

function printCyan() {
    printInColor "1;36" "$1"
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


function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

function checkSoftwareComponentIsInstalled() {
    local component=${1?:Component  is requreid}
    local expectedVersion=${2?:Minimal version is requreid}
    local referenceUrl=${3}
    command "$component" >> /dev/null 2>/dev/null
    [ $? -eq 127 ] && printError "$component is not installed. Check ${referenceUrl}" && exit 1
    local version=`$component --version | grep -oE "[0-9]{0,2}\.[0-9]{0,2}\.[0-9]{0,2}"`
    [[ "$expectedVersion" > "$version" ]] && printError "$component version $version. Expected version $expectedVersion or above. See ${referenceUrl}" && exit 1
    printGreen "`$component --version`"
}

function checkDockerComponentsAreInstalled() {
    checkSoftwareComponentIsInstalled "docker" "18.09.7" "https://docs.docker.com/install/"
    checkSoftwareComponentIsInstalled "docker-compose" "1.22.0" "https://docs.docker.com/compose/install/"
    checkSoftwareComponentIsInstalled "docker-machine" "0.16.0" "https://docs.docker.com/machine/install-machine/"
}


function grepIpAddr() {
    local text=$1
    echo `echo "$text" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`
}

function virtualboxHostIpAddr() {
    VBoxManage 1>/dev/null 2>/dev/null
    if [ "$?" -ne 0 ]; then
        printError "VBoxManage is not found. Check correct virtualbox's host address is used \n" >&2
        echo ""
        exit
    fi
    local vboxNetworkName=`VBoxManage list dhcpservers | grep -B 6 "Enabled:        Yes" | grep "NetworkName" | awk '{print $2}'`
    local vboxAddrLine=`VBoxManage list hostonlyifs | grep -B 12 "$vboxNetworkName" | grep -m 1 IPAddress`
    echo `grepIpAddr "$vboxAddrLine"`
}

function runningDockerContainer() {
    local containerName=${1:?Container name expected}
    echo `docker ps -aq -f name=${containerName}`
}

function localHostRunningDockerContainer() {
    unset DOCKER_HOST DOCKER_MACHINE_NAME DOCKER_CERT_PATH DOCKER_HOST DOCKER_TLS_VERIFY
    echo `runningDockerContainer $@`
}

function setDocker_LocalRegistryEnv() {
    if [ -z "$DOCKER_MACHINE_FLAGS" ]; then
        localRegistryRunning=`localHostRunningDockerContainer docker-registry`
        if [ -n "$localRegistryRunning" ]; then
            export DOCKER_REGISTRY=${DOCKER_REGISTRY-"`virtualboxHostIpAddr`:5000"};
            echo -e "\n\nUse DOCKER_REGISTRY=$DOCKER_REGISTRY\n\n"
        fi
    fi
}


function getDockerMachineName() {
    local org=${1:?Org is required}
    local hostOrg=`getHostOrgForOrg $1`
    if [ -n "$hostOrg" ]; then
        org=`getHostOrgForOrg $1`
    fi
    echo "$org.$DOMAIN"
}


function getDockerMachineNameFromColonDelimitedpair {
    local org_MachinePair=${1:?org:Machine is requreid}
    local orgMachineArray=($(IFS=':'; echo ${org_MachinePair}))
    local org=$org_MachinePair
    [[ -n "${orgMachineArray[1]}" ]] && org=${orgMachineArray[1]}
    echo "$org"
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
    sleep 1
    info "Connecting to org $1 in remote machine $machine"
    eval "$(docker-machine env ${machine})"
    export ORG=${1}
    env | grep DOCKER
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


function parseOrganizationsForDockerMachine() {
    #   excpecting external variable is declared by: declare -a ORGS_MAP
    local orgsArg=${@:?List of organizations is requreid}
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
    local org=${1:?Org is required}
    for org_MachinePair in $ORGS_MAP; do
        local orgMachineArray=($(IFS=':'; echo ${org_MachinePair}))
        if [ "${org}" == "${orgMachineArray[0]}" ]; then
            echo ${orgMachineArray[1]}
        fi
    done
}

function createHostsFileInOrg() {
    local org=${1:?Org is requreid}
    local node=${2:-${org}}

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
            sed -i.bak "/.*$node\.$DOMAIN*/d" org_hosts
        fi
    done

    createDirInMachine $org crypto-config
    copyFileToMachine ${org} org_hosts crypto-config/hosts_${node}
    rm org_hosts.bak org_hosts

    # you may want to keep this hosts file to append to your own local /etc/hosts to simplify name resolution
    # sudo cat hosts >> /etc/hosts
}

function createChannelAndAddOthers() {
    local channel=${1:?Channel is required}
    local first_org=${2:?First org is required}
    shift
    shift
    local orgs=$@

    connectMachine ${first_org}

    info "Creating channel $channel by $ORG"
    ORG=$first_org ./channel-create.sh ${channel}

    addOrgsToChannel $channel $first_org $orgs
}

function addOrgsToChannel() {
    local channel=${1:?Channel is required}
    local first_org=${2:?First org is required}
    shift
    shift
    local orgsToAdd=$@
    # First organization adds other organizations to the channel
    for org in ${orgsToAdd}
    do
        #        local orgIp=`getMachineIp $org`
        #        ORG=$first_org ./chaincode-invoke.sh common dns "[\"registerOrg\",\"${org}.${DOMAIN}\",\"$orgIp\"]"
        #        sleep 5
        info "Adding $org to channel $channel"
        ORG=$first_org ./channel-add-org.sh ${channel} ${org}
    done

    # All organizations join the channel
    for org in ${orgsToAdd}
    do
        info "Joining $org to channel $channel"
        connectMachine ${org}
        ORG=${org} ./channel-join.sh ${channel}
    done
}

function setOrdererIdentity() {
    local ORDERER_NAME=${1:?ORDERER_NAME is required}
    local ORDERER_DOMAIN=${2:?ORDERER_DOMAIN is required}
    local cryptoConfigPath=${3:-/etc/hyperledger/crypto-config}

    export CORE_PEER_LOCALMSPID=${ORDERER_NAME}.${ORDERER_DOMAIN:-example.com}
    export CORE_PEER_MSPCONFIGPATH=${cryptoConfigPath}/ordererOrganizations/${ORDERER_DOMAIN:-example.com}/users/Admin@${ORDERER_DOMAIN:-example.com}/msp
    export CORE_PEER_TLS_ROOTCERT_FILE=${ORDERER_GENERAL_TLS_ROOTCERT_FILE} #${cryptoConfigPath}/ordererOrganizations/${ORDERER_DOMAIN:-example.com}/orderers/${ORDERER_NAME:-orderer}.${ORDERER_DOMAIN:-example.com}/tls/ca.crt
}

function runAsOrderer() {
    local command=${1:?Command is required}
    shift
    local params=$@

    ORG_CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}
    ORG_CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}
    ORG_CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}

    setOrdererIdentity ${ORDERER_NAME} ${ORDERER_DOMAIN}

    ${command} ${params}
    local status=$?

    CORE_PEER_LOCALMSPID=${ORG_CORE_PEER_LOCALMSPID}
    CORE_PEER_MSPCONFIGPATH=${ORG_CORE_PEER_MSPCONFIGPATH}
    CORE_PEER_TLS_ROOTCERT_FILE=${ORG_CORE_PEER_TLS_ROOTCERT_FILE}
    return ${status}
}