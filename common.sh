: ${FABRIC_STARTER_HOME:=../..}

export FABRIC_STARTER_HOME=$FABRIC_STARTER_HOME
export PATH=$FABRIC_STARTER_HOME/:$PATH

orgEnvFile=$1
[[ -n $2 ]] && commonEnvFile=$2 || commonEnvFile="env-common"

[[ -z "$orgEnvFile" ]] && echo "Specify organization environment file as parameter: $0  env-org" && exit 1;
! [[ -f "$orgEnvFile" ]] && cp $FABRIC_STARTER_HOME/env_default "$orgEnvFile" && echo "Adjust environment in the $orgEnvFile file before create network" && exit 1

[[ -f "$commonEnvFile" ]] || (echo "File does not exists: $commonEnvFile" && exit 1);

source ./${commonEnvFile}
source ./${orgEnvFile}

[[ -d chaincode ]] || mkdir chaincode
copyChaincodeCommand="cp -r $FABRIC_STARTER_HOME/chaincode/* chaincode/"
echo "$copyChaincodeCommand" && `$copyChaincodeCommand`


network.sh -m down
docker rm -f $(docker ps -aq)
docker ps -a

export separateLine='-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------'
