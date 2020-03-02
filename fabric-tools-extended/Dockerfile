ARG DOCKER_REGISTRY
ARG FABRIC_VERSION
FROM ${DOCKER_REGISTRY:-docker.io}/hyperledger/fabric-tools:${FABRIC_VERSION:-1.4.4}

RUN apt-get update && apt-get install -y \
    gettext-base \
    iputils-ping \
    jq \
    nano \
    tree \
    telnet \
    vim \
  && rm -rf /var/lib/apt/lists/*

COPY templates /etc/hyperledger/templates
COPY container-scripts /etc/hyperledger/container-scripts
COPY docker-compose*.yaml /etc/hyperledger/

COPY middleware/ /usr/src/app/routes
COPY chaincode/ /opt/chaincode
COPY chaincode/node/ /opt/chaincode/node
COPY chaincode/node/reference /opt/chaincode/reference
COPY chaincode/go /opt/gopath/src



