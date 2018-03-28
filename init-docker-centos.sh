#!/usr/bin/env bash

sudo yum update -y

#install docker
 sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate \
                  docker-logrotate docker-selinux docker-engine-selinux docker-engine docker-ce


sudo yum install -y yum-utils device-mapper-persistent-data  lvm2

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce $FABRIC_DOCKER_VERSION

sudo groupadd docker
sudo usermod -aG docker $USER


echo
echo "---------------------------------"
echo "Docker-compose"
echo "---------------------------------"
sudo yum install -y docker-compose

echo
echo "---------------------------------"
echo "Install jq"
echo "---------------------------------"
#sudo yum install epel-release -y
#sudo yum install jq -y
jq --version


sudo systemctl start docker


echo
echo "---------------------------------"
echo "Relogin to apply the user into the 'docker' group"
echo "---------------------------------"
