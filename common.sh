: ${FABRIC_STARTER_HOME:=../..}

export FABRIC_STARTER_HOME=$FABRIC_STARTER_HOME
export PATH=$FABRIC_STARTER_HOME/:$PATH

loadEnvFile=$1
[[ -z $loadEnvFile ]] && echo "Specify organization environment file as parameter: $0  env-org" && exit 1;
! [[ -f "$loadEnvFile" ]] && cp $FABRIC_STARTER_HOME/env_default "$loadEnvFile" && echo "Adjust environment in the $loadEnvFile file before create network" && exit 1

source ./env-common
source ./$loadEnvFile

[[ -d chaincode ]] || mkdir chaincode
copyChaincodeCommand="cp -r $FABRIC_STARTER_HOME/chaincode/* chaincode/"
echo "$copyChaincodeCommand" && `$copyChaincodeCommand`


network.sh -m down
docker rm -f $(docker ps -aq)
docker ps -a

export separateLine='-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------'
