docker build -t olegabu/fabric-tools-extended -f ./fabric-tools-extended/Dockerfile --no-cache --build-arg FABRIC_VERSION=${FABRIC_VERSION:-latest} .
