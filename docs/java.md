# Build Fabric with support for chaincodes in Java

For Fabric version < 1.3.

This excercise has been tested with the following versions:
```bash
docker --version && java -version && go version
```

- Docker version 17.12.1-ce, build 7390fc6
- java version "1.8.0_181"
- go version go1.10.1 linux/amd64


Clean up. Delete all docker containers and images.
```bash
docker rm -f `(docker ps -aq)`
docker rmi -f `(docker images -aq)`
```

Create directories, environment and clone the latest source of Hyperledger Fabric from `master`.
```bash
mkdir -p ~/go
export GOPATH=~/go
mkdir -p $GOPATH/src/github.com/hyperledger
cd $GOPATH/src/github.com/hyperledger
git clone https://github.com/hyperledger/fabric
cd fabric
```

Build docker images with java enabled via `EXPERIMENTAL` flag.
```bash
export EXPERIMENTAL=true
make docker
```

Clone the latest source of java chaincode support.
```bash
cd $GOPATH/src/github.com/hyperledger
git clone https://github.com/hyperledger/fabric-chaincode-java 
cd fabric-chaincode-java
```

Build docker image for java chaincode `fabric-javaenv` and java `shim` for chaincode development.
```bash
./gradlew buildImage
./gradlew publishToMavenLocal
```

Install and instantiate *java* chaincode *fabric-chaincode-example* on channel *common*. 
Note the path to the source code is inside `cli` docker container and is mapped to the local 
`./chaincode/java/fabric-chaincode-example-gradle`
```bash
./chaincode-install.sh fabric-chaincode-example /opt/chaincode/java/fabric-chaincode-example-gradle java
./chaincode-instantiate.sh common fabric-chaincode-example '["init","a","10","b","0"]'
```