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

#RUN apt-get remove docker docker-engine docker.io containerd runc
RUN   apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

RUN     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

RUN    add-apt-repository \
          "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) \
          stable" \
    && apt-get update \
    && sudo apt-get install -y docker-ce docker-ce-cli containerd.io

RUN curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

RUN mkdir /wait-for-it && wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o /wait-for-it/wait-for-it.sh \
  && chmod +x /wait-for-it/wait-for-it.sh

COPY templates /etc/hyperledger/templates
COPY extra /etc/hyperledger/extra
COPY container-scripts /etc/hyperledger/container-scripts
COPY docker-compose*.yaml /etc/hyperledger/

COPY middleware/ /usr/src/app/routes
COPY chaincode/ /opt/chaincode
COPY chaincode/go /opt/gopath/src


WORKDIR /etc/hyperledger
