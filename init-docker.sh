#!/usr/bin/env bash

sudo apt-get update

#install docker
sudo apt-get remove -y docker docker-engine docker-ce docker.io

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "Real Docker fingerprint: 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88"
echo "Installed Docker's fingerprint:"
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

sudo groupadd docker
sudo usermod -aG docker $USER
sudo usermod -G docker $USER

echo
echo "---------------------------------"
read -n1 -r -p "Relogin to the apply the user into the 'docker' group"
