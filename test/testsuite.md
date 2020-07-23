# Hyperledger Fabric Starter Testing Suite

The Hyperledger Fabric Starter Testing Suite is a basic set of scripts and libraries designed to verify the correctnes on Hyperledger Fabric network installation using Fabric Starter, as well as the essential functionality of the Network deployed.

The Test Suite checks the operation of Fabric Network deployed locally or in docker-machine multihost environment.

## Features and functions tested

* Hyperledger containers for orderer and organizations are up and running
* Network is up and running
* Service channels were created
* New channels can be created in every organization
* Organizations with given permissions can join certain channels
* New chaincodes can be installed and instantiated in the channel

## Test Suite components

The Fabric starter Test sute components could be found in the ```./test``` folder of the Fabric Starter package.
```bash
test
├──  api                        #API action cripts folder
├──  cli                        #CLI action scripts folder
├──  verify                     #Veirfication scrips folder
├── common-test-env.sh          #Common testing environment variables and functions
├── local-test-env.sh           #Source script for testing the locally installed Network
├── lib-scenario.sh             #Testing scenario vars and functions
├── libs.sh                     #General Test Suite unctions
├── parse-common-params.sh      #Common parameters parsing library
├── run_scenario.sh             #Sample testing scenario script
├── Testsuite.MD                #This doc
└── vbox-test-env.sh            #Source script for testing the multihost Network deployment
```

## Scenarios

Testing scenarios utilize tipical action and verification scripts to perform some basic operations in the Network and to verify the results and the performance of the Hyperledger Fabric Network deployment. The sample scenario included demonstrates the testing process in several basic steps.

## Prerequisites

While running the sample scenario we assume that the Network with orderer and two organizations has been deployed locally or on two remote machines by mean of standard Fabric starter deployment scripts. Though any custom-tailored Network could be tested. You should have at hand some basic information on your deployment before running tests, e.g. organization names, domain or docker-machine names.

## Running tests

So the testing sequence is the following.
Decide what type of deployment (local or remote) you are going to test. For local instalation first source the local-test-env.sh file. The multihost VirtualBox deployment requires the vbox-test-env.sh to be sourced, e.g.:

```
source local-test-env.sh example.net first_org second_org
```
for local Network deloyment or

```
source vbox-test-env.sh example.net first_org second_org
```

for multihost deployment. Provide the domain, the first organization and the second organization as the arguments to the script. Now you are ready to run the testing scenario.

## Running scenario

The tipical way to run the testing scenario is to launch the scenario scipt in the following way:
```bash
DEBUG=false ./run_scenario.sh cli,api first_org second_org
```
Here you should provide the Fabric Starter interface types used to run basic operations in the network (cli for command-line and api for REST API interface, one or both, comma-separated), and names of two organizations participating in the testing procedure.

The DEBUG environment variabe being set to 'true' makes the scenario print all the debug information of the Fabric and the Test Suite both on your terminal and to the log file (fs_network_test.log). While the DEBUG var being set to 'false' (which is the default), only the brief details are printed on your terminal but all the debug data are still stored in the log file.

As a result you will get the output with operations performed (and also their exit codes), as well as the summary table containig the description of all the tests, exit codes and the runtime duration.
