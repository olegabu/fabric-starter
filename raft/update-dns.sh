#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/env.sh

raftDomains=${@:?List of raft domains with IPs is required in format: osn1.example.com:192.168.99.1}

export EXECUTE_BY_ORDERER=1

for domainIpVal in ${raftDomains}; do
  echo "Adding $domainIpVal to /etc/hosts"
  IFS=':' read -r -a domainConf <<<${domainIpVal}
  domainConf=($domainConf)
  echo "domainConf: $domainConf, ${domainConf[0]}, ${domainConf[1]}"
  ordererDomain=${domainConf[0]}
  domainIp=${domainConf[1]:?Ip address is required for domain}
  COMPOSE_PROJECT_NAME=$raftDomain docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer bash -c "echo -e '${domainIp}\twww.${ordererDomain} orderer.${ordererDomain}' >> /etc/hosts"
done
