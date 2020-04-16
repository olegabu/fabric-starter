# Acceptance test scenario

This test scenario implements simple acceptance test for the **fabric-starter** network with two organizations.

## Tested checkpoints

* Docker containers for orderer and organizations are up and running
* Service channel (common) exists
* Both orgs are added and joined to the 'common' channel

## Test environments

Scenario may work with a network deployed locally or in Virtual Box multihost environment.

## Prerequisites

Running **fabric-starter** network with orderer and two organizations deployed locally or in the Virtual Box environment.

The scenario provides script `create-test-network.sh` for qiuck test network deployment. Or you can use usual **fabric-starter** approaches.

#### Deploy test network

1. Go to the `./test` dir:

    ```bash
    cd ./fabric-starter
    cd ./test
    ```

1. Select local or Virtual Box test environment

    * For local environment run:

        ```bash
        source ./local-test-env.sh example.com
        ```

    * For Virtual Box environment run:

        ```bash
        source ./vbox-test-env.sh example.com
        ```

1. You can use existing or start new network:

    * Go the scenario dir:

        ```bash
        cd ./scenarios/01-fabric-starter-acceptance-test
        ```

    * Create test network:

        ```bash
        ./create-test-network.sh org1 org2.
        ```

## Run test scenario

1. Test network using CLI calls:

    ```bash
    ./run-scenario.sh cli org1 org2
    ```

1. Test network using REST API calls:

    ```bash
    ./run-scenario.sh api org1 org2
    ```
