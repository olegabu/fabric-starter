#!/usr/bin/env bash
cd ..
source lib.sh

USER_ID=`id -u`
USER_GRP=`id -g`

usageMsg="$0 backupLabel"
exampleMsg="$0 1"

backupLabel=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
backupDir="$PWD/backup/$backupLabel"

sudo rm -r -f "$backupDir"
mkdir -p "$backupDir"

echo; printInColor "1;32" "Stopping containers"
docker stop $(docker ps -aq)

echo; printInColor "1;32" "Backuping files"

docker run --rm \
-v /var/lib/docker:/docker \
-v ${backupDir}:/backup \
-v data:/opt/data \
-v crypto-config:/opt/crypto-config \
olegabu/fabric-tools-extended bash \
-c "cp -r -a /docker/volumes /backup && chown ${USER_ID}:${USER_ID} -R /opt/crypto-config && chown ${USER_ID}:${USER_ID} -R /opt/data && rm -rf opt/data/ldap/*/certs/* && cp -r -a /opt/data /backup && cp -r -a /opt/crypto-config /backup "

echo; printInColor "1;32" "Starting containers up"
docker start $(docker ps -aq)
