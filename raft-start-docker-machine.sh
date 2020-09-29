#!/usr/bin/env bash

source lib.sh

orig_orgs=$@

: ${RAFT0_PORT:=7050}
: ${RAFT1_PORT:=7150}
: ${RAFT2_PORT:=7250}
: ${RAFT_NODES_COUNT:=9}

: ${DOMAIN:=DOMAIN}

export DOMAIN RAFT0_PORT RAFT1_PORT RAFT2_PORT RAFT_NODES_COUNT

function main() {

  ######### START ####

  first_org=${1:-org1}
  shift
  orgs=$@

  export DOCKER_COMPOSE_ORDERER_ARGS="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"
  ORDERER_DOMAIN_1=${first_org}-osn.${DOMAIN}

  docker pull ${DOCKER_LOCAL_REGISTRY:-${DOCKER_REGISTRY:-docker.io}}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-stable}

  DOCKER_REGISTRY=${DOCKER_LOCAL_REGISTRY:-${DOCKER_REGISTRY:-docker.io}} ./clean.sh
  printYellow "Pre-generate orderer files on local host"
  DOCKER_REGISTRY=${DOCKER_LOCAL_REGISTRY:-${DOCKER_REGISTRY:-docker.io}} ORDERER_PROFILE=Raft ORDERER_DOMAIN=${ORDERER_DOMAIN_1} RAFT_NODES_COUNT=${RAFT_NODES_COUNT} COMPOSE_PROJECT_NAME=orderer.${DOMAIN} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d pre-install
  docker wait pre-install.orderer.${ORDERER_DOMAIN_1}
  printYellow "Pre-generate completed"
  docker run --rm  -v ./:/currdir ${DOCKER_LOCAL_REGISTRY:-${DOCKER_REGISTRY:-docker.io}}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-stable} chown -R `id -u`  crypto-config
#  sudo chown -R $USER crypto-config

  setMachineWorkDir ${first_org}
  export FABRIC_STARTER_HOME=${WORK_DIR}
  export WWW_PORT=81

  IFS=', ' read -r -a orgsArr <<<"$orgs"

  for org in ${orig_orgs}; do
    prepareOrg $org ${ORDERER_DOMAIN_1} &
    procId=$!
    sleep 1
  done

  wait ${procId}
  echo -e "\n\nRaft servers preparing completed\n\n"

  echo -e "\n\n"

  printYellow "1_raft-start-3-nodes: Starting 3 raft nodes on Org1:"
  connectMachine ${first_org}
  ORDERER_PROFILE=Raft RAFT_NODES_COUNT=9 ORDERER_DOMAIN=${ORDERER_DOMAIN_1} raft/1_raft-start-3-nodes.sh
  sleep 2

  IFS=', ' read -r -a orgsArr <<<"$orgs"
  echo -e "\n\n Raft: $orgs"
  raftIndex=3
  for currOrg in ${orgs}; do

    ORDERER_DOMAIN_ORG=${currOrg}-osn.${DOMAIN}

    startOrderer ${currOrg} ${ORDERER_DOMAIN_1} ${raftIndex} &
    procId=$!

    sleep 1
    raftIndex=$((raftIndex + 1))

    #    printYellow "2_raft-prepare-new-consenter.sh: Prepare ${currOrg} orderer:"
    #    ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} raft/2_raft-prepare-new-consenter.sh
    #    sleep 1

    #    printYellow " 3_raft-add-consenter ${currOrg}: Add new consenter to config: "
    #    connectMachine ${first_org}
    #    ORDERER_DOMAIN=${ORDERER_DOMAIN_1} raft/3_2_raft-add-consenter.sh orderer ${ORDERER_DOMAIN_ORG} ${RAFT0_PORT} ${WWW_PORT}
    #    sleep 5

    #    printYellow " 4_raft-start-consenter.sh ${currOrg}: Start Org2-raft0, wait for join: "
    #    connectMachine ${currOrg}
    #    ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} raft/4_raft-start-consenter.sh www.${ORDERER_DOMAIN_1}:${WWW_PORT}
    #    echo "Waiting  orderer.${ORDERER_DOMAIN_ORG}"
    #    sleep 5
  done

  [[ -n "${procId}" ]] && wait ${procId}

}

function createHostsFile() {
  local firstOrg=${1?:First org is required}
  local currOrg=${2?:Current org is required}
  local ordererDomain=${3:-${currOrg}-osn.${DOMAIN}}
  shift
  shift
  shift
  local restOrgs=$@

  local hosts=""
  local org
  local ip

  if [ "$currOrg" != "$firstOrg" ]; then
    ip=$(getMachineIp ${firstOrg})
    hosts="${ip} www.${ordererDomain} orderer.${ordererDomain} raft1.${ordererDomain} raft2.${ordererDomain}"
  fi

  # Collect IPs of remote hosts into a hosts file to copy to all hosts to be used as /etc/hosts to resolve all names

  local raftIndex=3
  for org in ${restOrgs}; do
    if [ "$currOrg" != "$org" ]; then
      ip=$(getMachineIp ${org})
      hosts="${hosts}\n${ip} raft${raftIndex}.${ordererDomain}"
    fi
    raftIndex=$((raftIndex + 1))
  done
  echo -e ${hosts} >crypto-config/hosts_${currOrg}
  copyFileToMachine $currOrg crypto-config/hosts_${currOrg} crypto-config/hosts
}

function prepareOrg() {
  local org=${1?: org is required}
  local ordererDomain=${2?: ordererDomain is required}

  bash -c "\
    source lib.sh;  \
    setMachineWorkDir ${org}; \
    export FABRIC_STARTER_HOME=${WORK_DIR}; \
    connectMachine ${org};  \
    docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-stable}; \
    docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION:-stable}; \
    docker pull ${DOCKER_REGISTRY:-docker.io}/hyperledger/fabric-orderer:${FABRIC_VERSION:-1.4.4}; \
    docker pull ${DOCKER_REGISTRY:-docker.io}/hyperledger/fabric-peer:${FABRIC_VERSION:-1.4.4}; \
    ./clean.sh; \
    copyDirToMachine $org crypto-config/ordererOrganizations/${ordererDomain} crypto-config/ordererOrganizations; \
    copyDirToMachine $org crypto-config/configtx crypto-config "

  createHostsFile ${first_org} ${org} ${ORDERER_DOMAIN_1} ${orgs}
  #    copyDirToMachine $org crypto-config/ordererOrganizations/${ordererDomain} crypto-config/ordererOrganizations
  #    copyDirToMachine $org crypto-config/configtx crypto-config

  #    copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/ crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}

  #
  #    copyFileToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/orderer.${ORDERER_DOMAIN_1}/tls/server.crt crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/orderer.${ORDERER_DOMAIN_1}/tls/server.crt
  #    copyFileToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/orderer.${ORDERER_DOMAIN_1}/tls/server.crt crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/orderer.${ORDERER_DOMAIN_1}/tls/ca.crt
  #local raftIdx
  #    for ((raftIdx=1; raftIdx< ${RAFT_NODES_COUNT}; raftIdx++)); do
  #        copyFileToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIdx}.${ORDERER_DOMAIN_1}/tls/server.crt crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIdx}.${ORDERER_DOMAIN_1}/tls/server.crt
  #        copyFileToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIdx}.${ORDERER_DOMAIN_1}/tls/server.crt crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIdx}.${ORDERER_DOMAIN_1}/tls/ca.crt
  #    done
  #
  #    copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/msp crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/msp
  #    copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/msp crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/users
  #    copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/msp crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/ca
  #    copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/msp crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/tlsca
  #    copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/msp crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/tlsca
  #    if [ "${org}" == "${first_org}" ]; then
  #        copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/orderer.${ORDERER_DOMAIN_1} crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/orderer.${ORDERER_DOMAIN_1}
  #        copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIndex}.${ORDERER_DOMAIN_1} crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIndex}.${ORDERER_DOMAIN_1}
  #        raftIndex=$((raftIndex+1))
  #        copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIndex}.${ORDERER_DOMAIN_1} crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIndex}.${ORDERER_DOMAIN_1}
  #        raftIndex=$((raftIndex+1))
  #    else
  #        copyDirToMachine $org crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIndex}.${ORDERER_DOMAIN_1} crypto-config/ordererOrganizations/${ORDERER_DOMAIN_1}/orderers/raft${raftIndex}.${ORDERER_DOMAIN_1}
  #        raftIndex=$((raftIndex+1))
  #    fi
}

function startOrderer() {
  local org=${1?: org is required}
  local ordererDomain=${2?: ordererDomain is required}
  local raftIndex=${3?: raftIndex is required}

  bash -c "\
        source lib.sh;  \
        setMachineWorkDir ${first_org}; \
        connectMachine ${org};
        COMPOSE_PROJECT_NAME=${org}.${DOMAIN} FABRIC_STARTER_HOME=${WORK_DIR} ORDERER_NAME=raft${raftIndex} ORDERER_DOMAIN=${ordererDomain}  docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d --force-recreate orderer www.orderer"
}

main $@
