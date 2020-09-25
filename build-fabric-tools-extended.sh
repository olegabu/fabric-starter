docker build -t kilpio/fabric-tools-extended -f ./fabric-tools-extended/Dockerfile --no-cache --build-arg FABRIC_VERSION=${FABRIC_VERSION:-latest} .
