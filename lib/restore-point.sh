#!/usr/bin/env bash
source ../lib.sh

usageMsg="$0 backupLabel"
exampleMsg="$0 1"

backupLabel=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
backupDir="backup/$backupLabel"

[ ! -d "$backupDir" ] && printRedYellow "Directory $backupDir doesn't exist" && exit 1

cd ..

printInColor "1;32" "Using backup from $backupDir"

echo; printInColor "1;32" "Stopping containers"

docker stop $(docker ps -aq)
sudo rm -rf /var/lib/docker/volumes/

echo; printInColor "1;32" "Restoring files"
sudo cp -R -a -f $backupDir/volumes/ /var/lib/docker/
sudo cp -R -a -f $backupDir/crypto-config/ ./

echo; printInColor "1;32" "Starting containers"
docker start $(docker ps -aq)





