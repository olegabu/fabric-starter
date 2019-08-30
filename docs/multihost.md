# Multi host deployment


## Multi host deployment with docker-machine

`Docker Machine` utility provides convenient command-line tool for managing multiple virtual machines, both running locally  with `virtualbox` and running 
in clouds such as Azure or AWS.

Having nodes deployed separately you will need to provide DNS name resolving so containers from different organizations can see each other.
   
There several options to implement this:   
- `Docker Swarm` automatically provides virtual sub-net for all nodes in Swarm. Recommended `only for test\dev` purposes as Swarm manager has unrestricted access to nodes. See [Swarm.md](swarm.md)
- `extra-hosts` setting which is added by docker-composer to each container's _/etc/hosts_ file. See [Extra hosts](#extra_hosts). 
- `DNS` service specific for particular blockchain network (either central or DNS-cluster). See [dns.md](dns.md).



## Prerequisites

Install [docker-machine](https://docs.docker.com/machine/get-started/).

## Quick start with virtual hosts on local dev machine

Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).


Use script [network-docker-machine-create.sh](./network-docker-machine-create.sh) to create a network with an arbitrary 
number of member organizations each running in its own virtual host.
```bash
./network-docker-machine-create.sh org1 org2 org3
```

There is an option to start orderer and the first organization nodes on the same host simultaneously:
```bash
./network-docker-machine-create.sh org1:orderer org2 org3
```


Of course you can override the defaults with env variables.
```bash
DOMAIN=mynetwork.org \
CHANNEL=a-b \
WEBAPP_HOME=/home/oleg/webapp \
CHAINCODE_HOME=/home/oleg/chaincode \
CHAINCODE_INSTALL_ARGS='example02 1.0 chaincode_example02 golang' \
CHAINCODE_INSTANTIATE_ARGS="a-b example02 [\"init\",\"a\",\"10\",\"b\",\"0\"] 1.0 collections.json AND('a.member','b.member')" \
./network-create-docker-machine.sh a b
```

The script [network-create-docker-machine.sh](./network-create-docker-machine.sh) combines
[host-create.sh](./host-create.sh) to create host machines with `docker-machine` and
[network-create.sh](./network-create.sh) to create container with `docker-compose`.

If you don't want to recreate hosts every time you can re-run `./network-create.sh` with the same arguments and 
env variables to recreate the network on the same remote hosts by clearing and creating containers.   

## Quick start with remote hosts on AWS EC2

* Define `amazonec2` driver for docker-machine and open ports in `docker-machine` security group.
* Make sure your AWS credentials are saved in env variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) 
or `~/.aws/credentials` or passed as arguments --amazonec2-access-key` and `--amazonec2-secret-key`.

* Determine the AWS `region` (e.g. `us-east-1` or `us-west-1`) and find the `vpc_id` 
corresponded to this region (or make sure the `region` has a default `vpc`)
* Determine which AWS `instance types` you are going to use (instance types with at least 4Gb RAM are recommended, e.g. `c5.xlarge`) 
* Provide AWS related flags environment for `docker-machine`:

```bash
export DOCKER_MACHINE_FLAGS="--driver amazonec2 \
    --amazonec2-region us-east-1 \
    --amazonec2-vpc-id vpc-0e3f0c2243772be49 \
    --amazonec2-instance-type c5.xlarge \
    --amazonec2-open-port 80 --amazonec2-open-port 7050 --amazonec2-open-port 7051 --amazonec2-open-port 4000"

```
More settings are described on the [driver page](https://docs.docker.com/machine/drivers/aws/).

* Then start the network:
```bash
./network-create-docker-machine.sh org1 org2 org3
```

## Quick start with remote hosts on Microsoft Azure

Define `azure` driver for docker-machine and open ports in network security groups. 
Give your subscription id (the one looking like `deadbeef-8bad-f00d-989d-5fbe969ccb9e`) and the script will prompt you
to login to your Microsoft account and authorize `Docker Machine for Azure` application to manage your Azure instances. 
More settings are described on the [driver page](https://docs.docker.com/machine/drivers/azure/).
```bash
DOCKER_MACHINE_FLAGS="--driver azure --azure-size Standard_A1 --azure-subscription-id <your subs-id> --azure-open-port 80 --azure-open-port 7050 --azure-open-port 7051 --azure-open-port 4000" \
./network-create-docker-machine.sh org1 org2
```

## Quick start with existing remote hosts

If you have already created remote hosts in the cloud or on premises you can connect docker-machine to these hosts and 
operate with the same scripts and commands.

Make sure the remote hosts have open inbound ports for Fabric network: 80, 4000, 7050, 7051 and for docker: 2376.

Connect via [generic](https://docs.docker.com/machine/drivers/generic/) driver 
to hosts *orderer*, *a* and *b* at specified public IPs with ssh private key `~/docker-machine.pem`.
```bash
docker-machine create --driver generic --generic-ssh-key ~/docker-machine.pem --generic-ssh-user ubuntu \
--generic-ip-address 34.227.123.456 orderer
docker-machine create --driver generic --generic-ssh-key ~/docker-machine.pem --generic-ssh-user ubuntu \
--generic-ip-address 54.173.123.457 a
docker-machine create --driver generic --generic-ssh-key ~/docker-machine.pem --generic-ssh-user ubuntu \
--generic-ip-address 54.152.123.458 b
```

Now the hosts are known to docker-machine and you can run `network-create.sh` script to create 
docker containers running the network and create organizations, channel and chaincode.
```bash
DOMAIN=mynetwork.org CHANNEL=a-b WEBAPP_HOME=/home/oleg/webapp CHAINCODE_HOME=/home/oleg/chaincode CHAINCODE_INSTALL_ARGS='example02 1.0 chaincode_example02 golang' CHAINCODE_INSTANTIATE_ARGS="a-b example02 [\"init\",\"a\",\"10\",\"b\",\"0\"] 1.0 collections.json AND('a.member','b.member')" \
./network-create.sh a b
```

## Manual start using Web Admin Dashboard without docker-machine

The first host is used for both orderer and org1 deployment.

If you like to use local docker registry (on all machines):
```bash
export DOCKER_REGISTRY=192.168.99.1:5000
``` 
 
#####orderer (and org1) machine:
```bash
    WWW_PORT=81 WORK_DIR=./ docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-multihost.yaml up -d
    BOOTSTRAP_IP=192.168.99.xx ORG=org1 MULTIHOST=true WORK_DIR=./ docker-compose -f docker-compose.yaml -f docker-compose-multihost.yaml -f docker-compose-api-port.yaml up -d
```

dd#####org2(,org3...) machine:
```bash
    BOOTSTRAP_IP=192.168.99.xx ORG=org2 MULTIHOST=true WORK_DIR=./ docker-compose -f docker-compose.yaml -f docker-compose-multihost.yaml -f docker-compose-api-port.yaml up -d
```

#####orderer machine again:
```bash 
    ./consortium-add-org.sh org1
    ./consortium-add-org.sh org2
    ...
```

#####orderer-IP(org1-IP):4000/admin:    
- add channel "common"
- instantiate chaincode: "dns"
- invoke dns.put ("192.168.99.xx" "orderer.example.com www.example.com peer0.org1.example.com www.org1.example.com")
- invoke dns.registerOrg  ("org2.example.com" "192.168.99.yy")
- organizations: add organization to channel "org2"
- invoke dns.registerOrg  ("org3.example.com" "192.168.99.zz")
- 
- organizations: add organization to channel "org3"
- install custom chaincode
- instantiate custom chaincode

#####org2-IP:4000/admin:
- join channel "common"
- install custom chaincode

#####org3-IP:4000/admin:
- join channel "common"
- install custom chaincode


# Drill down

To understand the script please read the below step by step instructions for the network 
of two member organizations org1 and org2.

### Create host machines

Create 3 hosts: orderer and member organizations org1 and org2.
```bash
docker-machine create orderer
docker-machine create org1
docker-machine create org2
```

### Create orderer organization

Tell the scripts to use extra multihost docker-compose yaml files.
```bash
export MULTIHOST=true
```

Copy config templates to the orderer host.
```bash
docker-machine scp -r templates orderer:templates
```

Connect docker client to the orderer host. 
The docker commands that follow will be executed on the host not local machine.
```bash
eval "$(docker-machine env orderer)"
```
 <a name="extra_hosts"></a>
Inspect created hosts' IPs and collect them into `hosts` file to copy to the hosts. This file will be mapped to the
docker containers' `/etc/hosts` to resolve names to IPs.
This is better done by the script.
Alternatively, edit `extra_hosts` in `docker-compose-multihost.yaml` and `docker-compose-orderer-multihost.yaml` to specify host IPs directly.

```bash
docker-machine ip orderer
docker-machine ip org1
docker-machine ip org2
```

Generate crypto material for the orderer organization and start its docker containers.
```bash
./generate-orderer.sh
docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-multihost.yaml up -d
```

### Create member organizations

Open a new console. Use env variables to tell the scripts to use multihost config yaml and to name your organization.
```bash
export MULTIHOST=true && export ORG=org1
```

Copy templates, chaincode and webapp folders to the host.
```bash
docker-machine scp -r templates $ORG:templates && docker-machine scp -r chaincode $ORG:chaincode && docker-machine scp -r webapp $ORG:webapp
```

Connect docker client to the organization host.
```bash
eval "$(docker-machine env $ORG)"
```

Generate crypto material for the org and start its docker containers.
```bash
./generate-peer.sh
docker-compose -f docker-compose.yaml -f docker-compose-multihost.yaml -f docker-compose-api-port.yaml up -d
```

To create other organizations repeat the above steps in separate consoles 
and giving them names by `export ORG=org2` in the first step.

### Add member organizations to the consortium

Return to the *orderer* console.

Now the member organizations are up and serving their certificates. 
The orderer host can download them to add to the consortium definition. 
```bash
./consortium-add-org.sh org1
./consortium-add-org.sh org2
```

### Create a channel and a chaincode

Return to the *org1* console.

The first organization creates channel *common* and joins to it.
```bash
./channel-create.sh common
./channel-join.sh common
```

And adds other organizations to channel *common*.
```bash
 ./channel-add-org.sh common org2
```

And installs and instantiates chaincode *reference*.
```bash
./chaincode-install.sh reference
./chaincode-instantiate.sh common reference
```

Test the chaincode by invoke and query.
```bash
./chaincode-invoke.sh common reference '["put","account","1","{\"name\":\"one\"}"]'
./chaincode-query.sh common reference '["list","account"]'
```

### Have other organizations join the channel

Return to *org2* console.

Join *common* and install *reference*.
```bash
./channel-join.sh common
./chaincode-install.sh reference
``` 

Test the chaincode by a query by *org2*.
```bash
./chaincode-query.sh common reference '["list","account"]'
```


