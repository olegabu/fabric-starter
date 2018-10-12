# Below code is copied form https://github.com/nodejs/docker-node/blob/master/Dockerfile-alpine.template
FROM node:8
EXPOSE 3000

FROM hyperledger/fabric-tools:${FABRIC_VERSION:-latest}

RUN apt-get update && apt-get install -y \
    gettext-base \
    jq \
    tree \
  && rm -rf /var/lib/apt/lists/*


