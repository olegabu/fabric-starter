# Hyperledger Fabric Starter Testing Suite

The Hyperledger Fabric Starter Testing Suite is a basic set of scripts and libraries designed to verify the correctness of Hyperledger Fabric network installation using Fabric Starter, as well as the essential functionality of a deployed network.

The Test Suite checks the operation of Fabric Network deployed locally or in docker-machine multihost environment. As a rule two organizations of the Network are involved in the testing process.

## Scenarios

Scenario is a set of (dependent) scripts running some basic operations in the Network and verifying the results and the performance of the Hyperledger Fabric Network.

Testing scenario calls a chain of scritps each performing a simple operation or analyzing it's successful completion.

## Features and functions to be tested

The Suite includes two scenarios. The first one implements a simple acceptance test for a network with two organizations.

The checkpoints tested:

* Hyperledger containers for orderer and organizations are up
* Service channels were created
* Both organizations were joined to the service channels

The second scenario tests the basic functionality of a network with two organizations.

The checkpoints tested:

* Network is up and running
* New channels can be created and are visible in apropriate orgs
* Organization can create a channel and can invite another org to the channel
* Invited organizations can join certain channels
* New chaincode can be installed and instantiated in a channel
* Data stored in a chaincode are visible for both orgs

## Test Suite components

The Fabric starter Test suite components are located in the ```./test``` folder of the Fabric Starter. The Suite can interact with the Fabric Starter in two ways: via the CLI or via the REST Fabric Starter interfaces. You can choose one or both of them for testing procedure.

```bash
test
├──  api                        #REST function calls scripts folder
├──  cli                        #CLI  function calls scripts folder
├──  libs                       #Utility libraries
├──  resources                  #Resources used in testing procedures (sample chaincodes etc.)
├──  scenarios                  #Testing scenarios scripts
├──  verify                     #Veirfication function calls scrips folder
├── local-test-env.sh           #Source script for testing the locally installed Network
├── testsuite.md                #This doc
└── vbox-test-env.sh            #Source script for testing the multihost Network deployment
```

## Prerequisites

To run tests in the Network we need orderer and two organizations, which has been deployed locally or on two remote machines. The network can be deployed by means of standard Fabric Starter deployment scripts or using our 'create-test-network.sh' script in the first scenario folder. Actually, any custom Network could be tested. You should have at hand some basic information on your deployment before running tests, e.g. organization names, domain or docker-machine names.

## Quick start. Run scenarios

* Change directory to the Fabric starter test dir:

```bash
cd ./test
```

* Select Fabric interface type (CLI or REST) and your deployment type (local or virtual box machines), the domain name and run in Fabric Starter dir:

```bash
source ./local-test-env.sh example.com
```

for local network or

```bash
source ./vbox-test-env.sh example.com
```

for virtual box-based network.

* Deploy the network using Fabric Starter scripts or run the Test Suite script to deploy the network with two organizations:

```bash
./scenarios/01-fabric-starter-acceptance-test/create-test-network.sh org1 org2
```

* Now proceed with the test scenarios. Description of each scenario is stored in 'scenario.md' file in scenario's directory.

The typical way to run the testing scenario is the following, providing interface type and org's names:

```bash

./scenarios/01-fabric-starter-acceptance-test/run-scenario.sh cli org1 org2

```

By defalt all the detailed debug information is written only into the log file. You may set the DEBUG environment variable to 'true' to print debug info on the terminal and into the fs_network_test.log log file:

```

```

In the end of a scenario execution As a result you will get the output with the description of all the tests performed (and also their exit codes), as well as the summary table:

```bash
STEP       TEST NAME                                                   RESULT     TIME ELAPSED (s)
---------- ----------------------------------------------------------- ---------- ----------
1_cli      Test 'Orderer containers'                                   OK:  (0)   0.575
2_cli      Test '[org1] containers'                                    OK:  (0)   0.695
3_cli      Test '[org2] containers'                                    OK:  (0)   0.692
4_cli      Test 'Organization in channel [common]'                     OK:  (0)   0.923
5_cli      Test 'Organization [org2] is in [common] channel'           OK:  (0)   1.154
6_cli      Test 'Organization [org1] joined the [common] channel'      OK:  (0)   0.679
7_cli      Test 'Organization [org2] joined the [common] channel'      OK:  (0)   0.701
---------- ----------------------------------------------------------- ---------- ----------
Start time: Mon Jul 27 13:56:45 MSK 2020, End time: Mon Jul 27 13:56:51 MSK 2020
Total tests run: 7
Total tests duration: 5.419 seconds
Total errors: 0
See debug log /home/fabric/sample/fabric-starter/test/fs_network_test.log
```

