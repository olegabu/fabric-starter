#!/usr/bin/env bash
source ../lib.sh
usageMsg="$0 backupLabel"
exampleMsg="$0 1"

backupLabel=${1:?`printUsage "$usageMsg" "$exampleMsg"`}


#cliContainerId=`docker ps --filter name="orderer.${DOMAIN}" -q`
#[ -z "$cliContainerId" ] && printRedYellow "Network is not started" && exit 1


cd ..

backupDir="backup/$backupLabel"

sudo rm -r -f "$backupDir"
mkdir -p "$backupDir"

echo; printInColor "1;32" "Stopping containers"
docker stop $(docker ps -aq)

echo; printInColor "1;32" "Backuping files"
sudo cp -R /var/lib/docker/volumes $backupDir
sudo cp -R crypto-config $backupDir

echo; printInColor "1;32" "Starting containers up"
docker start $(docker ps -aq)






