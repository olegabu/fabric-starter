#!/usr/bin/env bash

network.sh -m down
docker rm -f $(docker ps -aq)
docker volume rm $(docker volume ls -q -f "name=dockercompose_*")
docker volume prune -f
docker ps -a


###########################################################################
# Start
###########################################################################
if [ "$DEBUG_NOT_REMOVE_OLD_ARTIFACTS" == "" ]; then #sometimes in debug need not to remove old artifacts
    echo "Removinf old artifacts"
    network.sh -m removeArtifacts
fi

# generate peer artifacts
echo "THIS_ORG: $THIS_ORG"
network.sh -m generate-peer -o $THIS_ORG -a 4000 -w 8081

# generate/up orderer
network.sh -m generate-orderer -M $THIS_ORG
network.sh -m up-orderer

#start up main org
network.sh -m up-one-org -o $THIS_ORG -M $THIS_ORG -k common

#update policy for channel before adding other orgs
network.sh -m update-sign-policy -o $THIS_ORG -k common

echo
echo "Org '"$THIS_ORG"' is created and registered in channel 'common'."

#install chincodes
./install-cc.sh

#install chincodes in common channel
network.sh -m instantiate-chaincode -o $THIS_ORG -k common -n chaincode_example02 -I "${CHAINCODE_COMMON_INIT}"
echo "Warm up chaincode"
network.sh -m warmup-chaincode -o $THIS_ORG -k common -n chaincode_example02 -I "${CHAINCODE_QUERY_ARG}"

echo
echo "Main org '"$THIS_ORG"' is up. New organizations may be added by using 'main-register-new-org.sh'"
