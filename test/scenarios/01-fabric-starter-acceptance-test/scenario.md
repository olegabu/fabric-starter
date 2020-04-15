# Prerequisites

While running the sample scenario we assume that the Network with orderer and two organizations has been deployed 
locally or on two remote machines by mean of standard Fabric starter deployment scripts.
Though any custom-tailored Network could be tested. You should have at hand some basic information on your deployment before running tests, 
e.g. organization names, domain or docker-machine names.


## Start network tests

First, you shoud deploy the local or the virtual box Fabric test network in the following way:

* create network using script run-local-test-network.sh or run-vbox-test-network.sh
* source the local-test-env.sh or vbox-test-env.sh scripts
* run the start-network-test.sh


## Features and functions tested

* Docker containers for orderer and organizations are up and running
#* Network is up and running (connectivity: host name resolving, ports API (4000, 4001), PEER0 (7051, 8051), Orderer (7050), WWW 80)
* Service channel (common) exists
* Both orgs are in the 'common' channel

## HOWTO (example?)

*In the new console run run-local-test-network.sh or run-vbox-test-network.sh. This shoud deploy local or virtual box network 
with ordrer and to organizations org1 and org2 and example.com domain

* In the ./test directory:

```source ./local-test-env.sh example.com org1 org2```

or 

```source ./vbox-test-env.sh example.com org1 org2```

* in the scenario directory run

```
./start-network-test.sh cli org1 org2
```


Debug mode:

```
DEBUG=true ./start-network-test.sh cli org1 org2
```






