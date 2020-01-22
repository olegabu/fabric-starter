docker build -t olegabu/fabric-tools-extended -f ./fabric-tools-extended/Dockerfile --no-cache --build-arg FABRIC_VERSION=1.4.4 .
docker tag olegabu/fabric-tools-extended localhost:5000/olegabu/fabric-tools-extended
