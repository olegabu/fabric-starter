#!/usr/bin/env bash
cd ..
source lib.sh

USER_ID=`id -u`
USER_GRP=`id -g`

usageMsg="$0 backupLabel"
exampleMsg="$0 1"

backupLabel=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
backupDir="$PWD/backup/$backupLabel"

#sudo rm -r -f "$backupDir" TODO: check if backup dir exists and warn user
mkdir -p "$backupDir"

echo; printInColor "1;32" "Stopping containers"
docker stop $(docker ps -aq)

echo; printInColor "1;32" "Backuping files"

docker run --rm \
-v /var/lib/docker:/docker \
-v ${backupDir}:/backup \
-v $PWD/data:/opt/data \
-v $PWD/crypto-config:/opt/crypto-config \
olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest} bash \
-c "rm -rf /backup/* && cp -r -a /docker/volumes /backup && cp -r -a /opt/data /backup && cp -r -a /opt/crypto-config /backup && chown -R ${USER_ID}:${USER_GRP} /backup"

echo; printInColor "1;32" "Starting containers up"
docker start $(docker ps -aq)

docker restart $(docker ps -q -f "name=www")