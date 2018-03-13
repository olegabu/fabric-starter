: ${FABRIC_STARTER_HOME:=../..}

export FABRIC_STARTER_HOME=$FABRIC_STARTER_HOME
export PATH=$FABRIC_STARTER_HOME/:$PATH

loadEnvFile=$1
! [[ -f "$loadEnvFile" ]] && cp $FABRIC_STARTER_HOME/env_default "$loadEnvFile" && echo "Adjust environment in the $loadEnvFile file before create network" && exit 1

source ./$loadEnvFile

[[ -d chaincode ]] || mkdir chaincode
echo "cp -r $FABRIC_STARTER_HOME/chaincode/* chaincode/"
cp -r $FABRIC_STARTER_HOME/chaincode/* chaincode/

source ./env-common

network.sh -m down
docker ps -a

export separateLine='-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------'
