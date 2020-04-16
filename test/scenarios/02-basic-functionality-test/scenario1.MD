## Prerequisites


While running the sample scenario we assume that the Network with orderer and two organizations has been deployed locally or on two remote machines by mean of standard Fabric starter deployment scripts. Though any custom-tailored Network could be tested. You should have at hand some basic information on your deployment before running tests, e.g. organization names, domain or docker-machine names.

Pre-req script: .... -- what 
docker_build_images.sh
run-vbox-test-network.sh
souce 
run tests

* create network using script run-local-test-network.sh or run-vbox-test-network.sh

## Features and functions tested


basic-functionality:

* 'reference' chaincode and 'dns' chaincode (for virtual boxes) 
* New channels can be created in every organization
* Organization creates channel and can invite the other org
* Invited organizations can join certain channels
* New chaincodes can be installed and instantiated in the channel
* Chaincode invoke result is visible for both orgs -> <-

_Note_: this all should be usable for local and vbox networks

