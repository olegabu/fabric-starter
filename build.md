### Build project:
- build web application (admin dashboard) into admin-webapp.tgz
- copy admin-webapp.tgz to the fabric-starter-rest source dir
- build docker images: 
    - fabric-tools-extended
    - fabric-starter-rest
- additional steps for fabric 2x
    - build fabric-sdk-api
    - build fabric-starter-rest form fabric-tools-extended:1.0



git clone https://github.com/olegabu/fabric-starter-admin-web
./pack-admin-webapp.sh 

git clone https://github.com/olegabu/fabric-starter
./build-fabric-tools-extended.sh 1.4.4 1x
./build-fabric-tools-extended.sh 2.3.3 2x

git clone https://github.com/olegabu/fabric-starter-rest
./build-base.sh 1x
./build.sh 1x olegabu docker.io admin-webapp.tgz '' 
docker tag olegabu/fabric-starter-rest:1x olegabu/fabric-starter-rest:2x

git clone https://github.com/olegabu/fabric-sdk
gradle clean build -x test
docker build -t olegabu/fabric-sdk-api:2x .

