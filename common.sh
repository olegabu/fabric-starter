: ${FABRIC_STARTER_HOME:=../..}

export FABRIC_STARTER_HOME=$FABRIC_STARTER_HOME
export PATH=$FABRIC_STARTER_HOME/:$PATH

echo "common.sh"

orgEnvFile=$1
commonEnvFile=$2
[[ -n $commonEnvFile ]] || commonEnvFile="env-common"

[[ -z "$orgEnvFile" ]] && echo "Specify organization environment file as parameter: $0  env-org" && exit 1;
! [[ -f "$orgEnvFile" ]] && cp $FABRIC_STARTER_HOME/env_default "$orgEnvFile" && echo "Adjust environment in the $orgEnvFile file before create network" && exit 1

[[ -f "$commonEnvFile" ]] || (echo "File does not exists: $commonEnvFile" && exit 1);

echo -e "Load environment from: \n\t${commonEnvFile} \n\t${orgEnvFile}"
source ./${commonEnvFile}
source ./${orgEnvFile}

[[ -d chaincode ]] || mkdir chaincode
copyChaincodeCommand="cp -r $FABRIC_STARTER_HOME/chaincode/* chaincode/"
echo "$copyChaincodeCommand" && `$copyChaincodeCommand`


export separateLine='-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------'
