#!/usr/bin/env bash
cd ..
source lib.sh

usageMsg="$0 backupLabel"
exampleMsg="$0 1"

backupLabel=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

backupDir="$PWD/backup/$backupLabel"
[ ! -d "$backupDir" ] && printRedYellow "Directory $backupDir doesn't exist" && exit 1

printInColor "1;32" "Using backup from $backupDir"

docker rm -f tempCopy 2>/dev/null
docker run --name tempCopy --detach -v /var/lib/docker:/docker -v ${backupDir}:/backup olegabu/fabric-tools-extended bash -c "tail -f /var/log/dpkg.log"


printInColor "1;32" "\nRestoring files"
docker exec -t tempCopy bash -c "rm -rf /docker/volumes/*"
docker exec -t tempCopy bash -c "cp -r -a -f /backup/volumes /docker"
docker exec -t tempCopy bash -c "ls /docker/volumes"
docker rm -f tempCopy 1>/dev/null

sudo cp -r -a -f ${backupDir}/crypto-config/ ./
sudo cp -r -a -f ${backupDir}/data/ ./
