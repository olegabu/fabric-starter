# Hyperledger Fabric Starter Testing Suite

The Hyperledger Fabric Starter Testing Suite is a basic set of scripts and libraries designed to verify the correctness of Hyperledger Fabric network installation using Fabric Starter, as well as the essential functionality of a deployed network.

The Testing Suite verifies the operation of Fabric Network deployed locally or in docker-machine multihost environment. You need a Network at least with two organizations to run test scenarios.

## Scenarios

The scenario is a shell script, which calls in sequence a set of code snippets that execute some elementary network operations and verify their results.

## Functionality tested

The Testing Suite includes two out-of-the-box scenarios. They can be found in the './test/scenarios' directory. Description of each scenario is stored in 'scenario.md' file in each scenario's directory. Use run-scenario.sh script to run the scenario.

### Acceptance test scenario

The first scenario implements a simple acceptance test for a network with two organizations.

The checkpoints tested:

* Hyperledger Fabric containers for orderer and organizations are up
* Service channels were created
* Both organizations were joined to the service channels

### Basic functionality test scenario

The second scenario tests the basic functionality of a network with two organizations.

The checkpoints tested:

* Network is up and running
* New channels can be created and are visible in appropriate organizations
* Organization can create a channel and can invite another org to the channel
* Invited organizations can join certain channels
* New chaincode can be installed and instantiated in a channel
* Data stored in a chaincode are visible for both organizations

## Testing Suite components

The components of the Testing Suite are located in the ```./test``` folder of the Fabric Starter. The Suite can interact with the Fabric Starter in two ways: via the CLI or via the REST Fabric Starter interfaces. You can choose one or both of them when running tests.

```bash
test
├──  api                        #Scripts for REST function calls
├──  cli                        #Scripts for CLI function calls
├──  libs                       #Utility libraries
├──  resources                  #Resources used in test procedures (sample chaincodes etc.)
├──  scenarios                  #Test scenarios scripts
├──  verify                     #Veirfication scrips
├── local-test-env.sh           #Source script for testing the locally installed Network
├── testsuite.md                #This doc
└── vbox-test-env.sh            #Source script for testing the multihost Network deployment
```

## Prerequisites

The most steps of the included scenarios require the orderer and two organizations, which have been deployed locally or on two remote machines.However for some test in the Suite the configuration of the Network may differ.

The Network can be deployed by means of standard Fabric Starter deployment scripts or using the provided 'create-test-network.sh' script in the first scenario folder. The script creates the Network with one orderer and two organizations. Actually, any custom Network can be tested.

You should have at hand some basic information on your deployment before running tests, e.g. organization names, domain or docker-machine names.

## Quick start. Run scenarios

* Change working directory to the Fabric starter test directory:

```bash
cd ./test
```

* Choose local or multihost network type to test. In the Fabric Starter Testing Suite directory run

```bash
source ./local-test-env.sh example.com
```

command for local network or

```bash
source ./vbox-test-env.sh example.com
```

for virtual box-based (multihost) network. Provide the domain name as an argument (here 'example.com').

* Deploy the network using Fabric Starter scripts or run the Test Suite script to deploy the network with two organizations (if you have not done it yet):

```bash
./scenarios/01-fabric-starter-acceptance-test/create-test-network.sh org1 org2
```

* Now proceed with test scenarios.

The first argument of the scenario script is the Fabric Starter interface type to be used: 'cli' for the command line, and 'api' for the REST. You can provide one of them or both, comma separated. Next arguments are the name of the organizations, which you choose for testing.

The typical way to run the test scenario is the following:

```bash
./scenarios/01-fabric-starter-acceptance-test/run-scenario.sh cli org1 org2
```

* Debug information

All the detailed debug information is written only into the log file by default. You may set the DEBUG environment variable to 'true' to print debug info on the terminal and into the 'fs_network_test.log' log file:

```bash
DEBUG=true ./scenarios/02-basic-functionality-test/run-scenario.sh api org1 org2
```

At the end of a scenario execution you will get the summary table with the description of all the tests performed (and also their exit codes):

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
