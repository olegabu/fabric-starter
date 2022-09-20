ARG DOCKER_REGISTRY
ARG FABRIC_VERSION
ARG FABRIC_STARTER_VERSION
FROM ${DOCKER_REGISTRY:-docker.io}/hyperledger/fabric-tools:${FABRIC_VERSION:-1.4.9} as fabrictools


#FROM node:12-alpine as node_base
RUN apk update \
    && apk add \
    bash \
    busybox-extras \
    curl \
    jq \
    gettext \
    openssl \
    tree \
    vim

# copy fabic executables/configs
#COPY --from=fabrictools /usr/local/bin/cryptogen /usr/local/bin
#COPY --from=fabrictools /usr/local/bin/configtxgen /usr/local/bin
#COPY --from=fabrictools /usr/local/bin/configtxlator /usr/local/bin
#COPY --from=fabrictools /usr/local/bin/peer /usr/local/bin
#COPY --from=fabrictools /etc/hyperledger/fabric /etc/hyperledger/fabric


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





