FROM hyperledger/fabric-tools:${FABRIC_VERSION:-latest}

RUN apt-get update && apt-get install -y \
    gettext-base \
    jq \
    tree \
  && rm -rf /var/lib/apt/lists/*

