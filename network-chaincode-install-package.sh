source lib/util/util.sh
source lib.sh

setDocker_LocalRegistryEnv

export MULTIHOST=true
: ${CHANNEL:=common}

chaincode_instantiate_args=${CHAINCODE_INSTANTIATE_ARGS:-common reference}
chaincode_install_package=${CHAINCODE_INSTALL_PACKAGE}

declare -a ORGS_MAP=${@:-org1}
orgs=`parseOrganizationsForDockerMachine ${ORGS_MAP}`
first_org=${orgs%% *}

# Set WORK_DIR as home dir on remote machine
setMachineWorkDir $first_org

# First organization install chaincode package
connectMachine ${first_org}

info "Install chaincode package"
./chaincode-install-package.sh ${chaincode_install_package}
sleep 10

info "Instantiate chaincode"
./chaincode-instantiate.sh ${chaincode_instantiate_args}
sleep 5
