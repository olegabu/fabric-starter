#!/usr/bin/env bash
cd ..
source lib.sh

USER_ID=`id -u`
USER_GRP=`id -g`

usageMsg="$0 backupLabel"
exampleMsg="$0 1"

backupLabel=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

backupDir="$PWD/backup/$backupLabel"
[ ! -d "$backupDir" ] && printRedYellow "Directory $backupDir doesn't exist" && exit 1

printInColor "1;32" "Using backup from $backupDir"

docker rm -f tempCopy 2>/dev/null
docker run --name tempCopy --detach \
-v /var/lib/docker:/docker \
-v $PWD/data:/opt/data \
-v $PWD/crypto-config:/opt/crypto-config \
-v $PWD/appstore:/opt/appstore \
-v ${backupDir}:/backup \
olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest} bash -c "tail -f /var/log/dpkg.log"

printInColor "1;32" "\nRestoring files"
docker exec -t tempCopy bash -c "rm -rf /docker/volumes/*"
docker exec -t tempCopy bash -c "cp -r -a -f /backup/volumes /docker"
docker exec -t tempCopy bash -c "ls /docker/volumes"
docker exec -t tempCopy bash -c "chown -R -v ${USER_ID}:${USER_GRP} /opt/data"
docker exec -t tempCopy bash -c "chown -R -v ${USER_ID}:${USER_GRP} /opt/crypto-config"
docker exec -t tempCopy bash -c "chown -R -v ${USER_ID}:${USER_GRP} /opt/appstore"
docker exec -t tempCopy bash -c "cp -r /backup/data/* /opt/data/"
docker exec -t tempCopy bash -c "cp -r /backup/crypto-config/* /opt/crypto-config/"
docker exec -t tempCopy bash -c "cp -r /backup/appstore/* /opt/appstore/"
docker exec -t tempCopy bash -c "chown -R root:root /docker/volumes"

docker rm -f tempCopy 1>/dev/null

