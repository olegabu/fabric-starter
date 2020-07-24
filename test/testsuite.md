# Hyperledger Fabric Starter Testing Suite

The Hyperledger Fabric Starter Testing Suite is a basic set of scripts and libraries designed to verify the correctnes on Hyperledger Fabric network installation using Fabric Starter, as well as the essential functionality of the Network deployed.

The Test Suite checks the operation of Fabric Network deployed locally or in docker-machine multihost environment.

## Features and functions tested

* Hyperledger containers for orderer and organizations are up and running
* Network is up and running
* Service channels were created
* New channels can be created in every organization
* Organizations with given permissions can join certain channels
* New chaincodes can be installed, instantiated in the channel, as well as invoked and querried

## Test Suite components

The Fabric starter Test sute components could be found in the ```./test``` folder of the Fabric Starter package.

```bash
test
├──  api                        #API action cripts folder
├──  cli                        #CLI action scripts folder
├──  libs                       #Utility libraries required for running tests
├──  resources                  #Resources used in testing procedures (sample chaincodes etc.)
├──  scenarios                  #Testing scenarios scripts
├──  verify                     #Veirfication scrips folder
├── local-test-env.sh           #Source script for testing the locally installed Network
├── testsuite.md                #This doc
└── vbox-test-env.sh            #Source script for testing the multihost Network deployment
```

## Scenarios

Testing scenarios utilize tipical action and verification scripts to perform some basic operations in the Network and to verify the results and the performance of the Hyperledger Fabric Network deployment. The sample scenarios included demonstrate the testing process in several basic steps.

## Prerequisites

While running the sample scenario we assume that the Network with orderer and two organizations has been deployed locally or on two remote machines by mean of standard Fabric starter deployment scripts. Though any custom-tailored Network could be tested. You should have at hand some basic information on your deployment before running tests, e.g. organization names, domain or docker-machine names.

## Running scenarios

The detailed description of running test scenario scripts could be found in appropriate 'scenario.md' file in each scenario directory.

The typical way to run the testing scenario is to launch the scenario script in the following way:

```bash

DEBUG=false ./run_scenario.sh [cli|api|cli,api] first_org second_org

```

Here you should provide one of the Fabric Starter interface types used to run basic operations in the network (cli for command-line and api for REST API interface, one or both, comma-separated), and names of two organizations participating in the testing procedure.

The DEBUG environment variable being set to 'true' makes the scenario print all the debug information of the Fabric and the Test Suite both on your terminal and to the log file (fs_network_test.log). While the DEBUG var being set to 'false' (by default), only the brief details are printed on your terminal but all the debug data are still stored in the log file.

As a result you will get the output with the description of all the tests performed (and also their exit codes), as well as the summary table.
