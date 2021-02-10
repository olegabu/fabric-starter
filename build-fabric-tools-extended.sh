docker build -t olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest} -f ./fabric-tools-extended/Dockerfile --no-cache --build-arg FABRIC_VERSION=${FABRIC_VERSION:-1.4.9} .
