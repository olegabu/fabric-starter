#!/usr/bin/env bash

sudo apt-get update

#install docker
echo "---------------------------------"
echo "Remove old dockers if any"

sudo apt-get remove -y docker docker-engine docker-ce docker.io

echo "---------------------------------"
echo "Install docker prerequisities"
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "Real Docker fingerprint: 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88"
echo "Installed Docker's fingerprint:"
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update

echo "---------------------------------"
echo "Install docker-ce:$FABRIC_DOCKER_VERSION"
sudo apt-get install -y docker-ce $FABRIC_DOCKER_VERSION #e.g. FABRIC_DOCKER_VERSION=docker-ce-18.03.0.ce

sudo groupadd docker
sudo usermod -aG docker $USER

echo
echo "---------------------------------"
echo "Relogin to apply the user into the 'docker' group"
echo "---------------------------------"
