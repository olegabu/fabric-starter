ARG FABRIC_VERSION
FROM hyperledger/fabric-tools:${FABRIC_VERSION:-latest}

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
COPY scripts /etc/hyperledger/scripts
COPY docker-compose*.yaml /etc/hyperledger/

