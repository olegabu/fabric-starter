ARG DOCKER_REGISTRY
ARG FABRIC_VERSION
ARG FABRIC_STARTER_VERSION
FROM ${DOCKER_REGISTRY:-docker.io}/hyperledger/fabric-tools:${FABRIC_VERSION:-1.4.9}

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
COPY raft /etc/hyperledger/raft
COPY ordering-start.sh /etc/hyperledger/


COPY templates /usr/src/app/templates
COPY container-scripts /usr/src/app/container-scripts
COPY docker-compose*.yaml /usr/src/app/


COPY middleware/ /etc/hyperledger/routes

COPY middleware/ /usr/src/app/routes
COPY chaincode/ /opt/chaincode
COPY chaincode/go /opt/gopath/src





