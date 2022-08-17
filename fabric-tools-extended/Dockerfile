ARG DOCKER_REGISTRY
ARG FABRIC_VERSION

ARG NODE_IMAGE
ARG CHAINCODE_VERSION_DIR

FROM ${NODE_IMAGE:-'node:12-alpine'} as node_base
ARG CHAINCODE_VERSION_DIR
ARG CHAINCODE_PACKAGE_FILE=dns-chaincode.tgz

COPY ${CHAINCODE_VERSION_DIR}/node/dns ./${CHAINCODE_VERSION_DIR}/node/dns

RUN cd ${CHAINCODE_VERSION_DIR}/node/dns && \
    npm install && npm pack && \
    mv dns-*.tgz ../${CHAINCODE_PACKAGE_FILE} && \
    rm -rf node_modules && \
    rm package-lock.json && \
    cd .. && \
    tar xzf ${CHAINCODE_PACKAGE_FILE} && \
    mv package src && \
    tar czf code.tar.gz src && \
    echo '{"path":"","type":"node","label":"dns_1.0"}' > metadata.json && \
    tar czf ${CHAINCODE_PACKAGE_FILE} code.tar.gz metadata.json && \
    rm -rf ./src ./code.tar.gz ./metadata.json


FROM ${DOCKER_REGISTRY:-docker.io}/hyperledger/fabric-tools:${FABRIC_VERSION:-latest} as fabrictools
ARG CHAINCODE_VERSION_DIR
#alpine
RUN apk update \
    && apk add \
    bash \
    busybox-extras \
    curl \
    jq \
    gettext \
    openssl \
    tree \
    vim || true

#ubuntu
RUN apt-get update && apt-get install -y \
    gettext-base \
    iputils-ping \
    jq \
    nano \
    tree \
    telnet \
    vim  && \
    rm -rf /var/lib/apt/lists/* || true

COPY templates /etc/hyperledger/templates
COPY container-scripts /etc/hyperledger/container-scripts
COPY docker-compose*.yaml /etc/hyperledger/
COPY raft /etc/hyperledger/raft
COPY https /etc/hyperledger/https
COPY ordering-start.sh /etc/hyperledger/


COPY templates /usr/src/app/templates
COPY container-scripts /usr/src/app/container-scripts
COPY docker-compose*.yaml /usr/src/app/


COPY middleware/ /etc/hyperledger/routes

COPY middleware/ /usr/src/app/routes
COPY chaincode/ /opt/chaincode
COPY chaincode/go /opt/gopath/src

COPY --from=node_base ./${CHAINCODE_VERSION_DIR}/node /opt/${CHAINCODE_VERSION_DIR}/node
