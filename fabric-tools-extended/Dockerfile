ARG DOCKER_REGISTRY
ARG FABRIC_VERSION
FROM ${DOCKER_REGISTRY:-docker.io}/hyperledger/fabric-tools:${FABRIC_VERSION:-latest}

RUN apt-get update && apt-get install -y \
    gettext-base \
    iputils-ping \
    jq \
    nano \
    tree \
    telnet \
    vim \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /wait-for-it && wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o /wait-for-it/wait-for-it.sh \
  && chmod +x /wait-for-it/wait-for-it.sh

COPY templates /etc/hyperledger/templates
COPY container-scripts /etc/hyperledger/container-scripts
COPY docker-compose*.yaml /etc/hyperledger/

COPY middleware/ /usr/src/app/routes
COPY chaincode/ /opt/chaincode
COPY chaincode/go /opt/gopath/src



