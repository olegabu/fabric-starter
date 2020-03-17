## Prerequisites


While running the sample scenario we assume that the Network with orderer and two organizations has been deployed locally or on two remote machines by mean of standard Fabric starter deployment scripts. Though any custom-tailored Network could be tested. You should have at hand some basic information on your deployment before running tests, e.g. organization names, domain or docker-machine names.

Pre-req script: .... -- what 

* create network using script run-local-test-network.sh or run-vbox-test-network.sh

## Features and functions tested

start-network:
* Docker containers for orderer and organizations are up and running
#* Network is up and running (connectivity: host name resolving, ports API (4000, 4001), PEER0 (7051, 8051), Orderer (7050), WWW 80)
* Service channel (common) exists)
* Both orgs are in the 'common' channel

basic-functionality:
* 'reference' chaincode and 'dns' chaincode (for virtual boxes) 
* New channels can be created in every organization
* Organization can invite the other org
* Organizations invited can join certain channels
* New chaincodes can be installed and instantiated in the channel
* Chaincode invoke result is visible for both orgs -> <-

_Note_: this all should be usable for local and vbox networks

