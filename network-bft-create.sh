#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh

: ${SYSTEM_CHANNEL_ID:=bftchannel}
: ${FABRIC_VERSION:=1.3.0}

export FABRIC_VERSION

function copyConfigs {
    local org=${1:?-Org must be specified}
    local kind=${2:?-"orderer" or "frontend" must be specified}
    local ordererNodesHostsConfigList=${3:?-"ordererNodesHostsConfigList" must be specified}
    local orderingNodeId=${4:?-"orderingNodeId" must be specified}
    local ordererNodesIdsList=${5:?-"ordererNodesIdsList" must be specified}

    local orgConfigPath=crypto-config/bft/${org}-${kind}
    mkdir -p ${orgConfigPath}
    cp -r templates/bft/config ${orgConfigPath}
    cp -r templates/bft/fabric ${orgConfigPath}
    echo -e ${ordererNodesHostsConfigList} >> ${orgConfigPath}/config/hosts.config

    export ORG=$kind.$org
    envsubst < templates/bft/config/node.config > ${orgConfigPath}/config/node.config

    export ORDERERS_COUNT=${orderingNodeId}
    export ORDERER_NODES_IDS=${ordererNodesIdsList}
    envsubst < templates/bft/config/system.config > ${orgConfigPath}/config/system.config
}

function copyKeys {
    local orgs=${1:?Orgs must be passed in}

    local ordererNodeId=0
    local frontendNodeId=1000

    for orgFrom in ${orgs}; do
        for kind in "orderer" "frontend"; do
            mspPath=crypto-config/ordererOrganizations/${kind}.${orgFrom}.${DOMAIN}/orderers/${kind}.${kind}.${orgFrom}.${DOMAIN}/msp
            docker-compose -f docker-compose-util.yaml run --rm cli.bft sh -c "cp ${mspPath}/keystore/`ls ${mspPath}/keystore/` 'crypto-config/bft/${orgFrom}-${kind}/config/keys/keystore.pem'"
            for orgTo in ${orgs}; do
                local idPropertyName="${kind}NodeId"
#                cp -r ${mspPath}/tlscacerts/tlsca.${DOMAIN}-cert.pem "crypto-config/bft/${orgTo}-orderer/config/keys/cert${!idPropertyName}.pem"
#                cp -r ${mspPath}/tlscacerts/tlsca.${DOMAIN}-cert.pem "crypto-config/bft/${orgTo}-frontend/config/keys/cert${!idPropertyName}.pem"
                cp -r ${mspPath}/signcerts/${kind}.${kind}.${orgFrom}.${DOMAIN}-cert.pem "crypto-config/bft/${orgTo}-orderer/config/keys/cert${!idPropertyName}.pem"
                cp -r ${mspPath}/signcerts/${kind}.${kind}.${orgFrom}.${DOMAIN}-cert.pem "crypto-config/bft/${orgTo}-frontend/config/keys/cert${!idPropertyName}.pem"
            done
        done

#        docker-compose -f docker-compose-util.yaml run --rm cli.bft sh -c "cp crypto-config/bft/${orgFrom}-frontend/fabric/msp/admincerts/Admin@frontend.example.com-cert.pem crypto-config/bft/${orgFrom}-frontend/fabric/msp/admincerts/admincert.pem \
#        && cp crypto-config/bft/${orgFrom}-frontend/fabric/msp/cacerts/ca.frontend.example.com-cert.pem crypto-config/bft/${orgFrom}-frontend/fabric/msp/cacerts/cacert.pem \
#        && cp crypto-config/bft/${orgFrom}-frontend/fabric/msp/signcerts/frontend.${orgFrom}.frontend.example.com-cert.pem crypto-config/bft/${orgFrom}-frontend/fabric/msp/signcerts/peer.pem "

        ordererNodeId=$((ordererNodeId +1))
        frontendNodeId=$((frontendNodeId +1000))
    done
}


orgs=${@:-org1}
first_org=${1:-org1}

if [ "$1" == "clean" ] ; then

    ./clean.sh

    shift
    orgs=${@:-org1}
    first_org=${1:-org1}

    echo "ORGS: $orgs"

    ordererNodeId=0
    frontentNodeId=1000
    nodePort=11000
    for org in ${orgs}; do
        ordererNodesHostsConfigList="$ordererNodesHostsConfigList\n${ordererNodeId} orderer.orderer.${org}.${DOMAIN} ${nodePort}"
        ordererNodesIdsList="${ordererNodesIdsList}${ordererNodesIdsList+,}${ordererNodeId}"
        frontendIdsList="$frontendIdsList${frontentNodeId},"
        frontendAddressesList="${frontendAddressesList}${frontendAddressesList+,}frontend.frontend.${org}.${DOMAIN}:7050"
        ordererNodeId=$((ordererNodeId + 1))
        frontentNodeId=$((frontentNodeId + 1000))
#        nodePort=$((nodePort + 1000))
    done


    for org in ${orgs}; do

        copyConfigs $org orderer "$ordererNodesHostsConfigList" "$ordererNodeId" "$ordererNodesIdsList"
        copyConfigs $org frontend "$ordererNodesHostsConfigList" "$ordererNodeId" "$ordererNodesIdsList"

        export ORG=$org
        envsubst < templates/bft/cryptogen-orderer-bft-template.yaml > crypto-config/bft/cryptogen-orderer-bft.yaml
        [ "$org" == "$first_org" ] && docker-compose -f docker-compose-util.yaml run --rm cli.bft cryptogen generate --config=crypto-config/bft/cryptogen-orderer-bft.yaml

        orgConfigPath=crypto-config/bft/${org}-frontend
        mkdir -p "${orgConfigPath}/fabric"
        docker-compose -f docker-compose-util.yaml run --rm cli.bft cp -r "crypto-config/ordererOrganizations/frontend.${org}.${DOMAIN}/orderers/frontend.frontend.${org}.${DOMAIN}/msp" "${orgConfigPath}/fabric"
        envsubst <"templates/bft/fabric/orderer.yaml" >"${orgConfigPath}/fabric/orderer.yaml"

    done


    copyKeys "${orgs}"
    export ORDERER_FRONTEND_ADDRESSES=$frontendAddressesList ORG=org2
    envsubst < "templates/configtx-template.yaml" > "crypto-config/configtx.yaml"

fi

./clean.sh keepCrypto

#docker rm -f frontend.frontend.org1.example.com frontend.frontend.org2.example.com


ORG=org2 COMPOSE_PROJECT_NAME=org2 docker-compose up -d

sleep 2

mkdir -p crypto-config/config
docker-compose -f docker-compose-util.yaml run --rm cli.bft configtxgen -configPath crypto-config/ -outputBlock crypto-config/config/genesisblock -profile BFTGenesis -channelID ${SYSTEM_CHANNEL_ID}


ordererNodeId=0
BFT_ORDERER_PORT_1=11000
BFT_ORDERER_PORT_2=11001
BFT_ORDERER_PORT_3=11002
for org in ${orgs}; do
    cp crypto-config/config/genesisblock crypto-config/bft/${org}-orderer/config

    export ORG=$org COMPOSE_PROJECT_NAME=ord_$org ORDERER_NODE_ID=$ordererNodeId
    export BFT_ORDERER_PORT_1 BFT_ORDERER_PORT_2 BFT_ORDERER_PORT_3
    docker-compose -f docker-compose-orderer-bft.yaml up -d
    ordererNodeId=$((ordererNodeId + 1))
    BFT_ORDERER_PORT_1=$((BFT_ORDERER_PORT_1 + 1000))
    BFT_ORDERER_PORT_2=$((BFT_ORDERER_PORT_2 + 1000))
    BFT_ORDERER_PORT_3=$((BFT_ORDERER_PORT_3 + 1000))
    
    sleep 2
done


frontendNodeId=1000
ordererListenPort=7050

export RECV_PORT=9999
for org in ${orgs}; do
    sleep 2
    cp crypto-config/config/genesisblock crypto-config/bft/${org}-frontend/config

    export ORG=$org COMPOSE_PROJECT_NAME=$org FRONTEND_NODE_ID=$frontendNodeId
    export ORDERER_LISTEN_PORT=$ordererListenPort

    docker-compose -f docker-compose-orderer-frontend-bft.yaml up -d
    frontendNodeId=$((frontendNodeId + 1000))
#    ordererListenPort=$((ordererListenPort - 1))
done

exit

export ORG=org1 COMPOSE_PROJECT_NAME=org1 FRONTEND_NODE_ID=1000
export ORDERER_LISTEN_PORT=7050 RECV_PORT=9999

#export DEBG="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"
docker-compose -f docker-compose-orderer-frontend-bft.yaml up -d

export ORG=org2 COMPOSE_PROJECT_NAME=org2 FRONTEND_NODE_ID=2000
export ORDERER_LISTEN_PORT=7049 RECV_PORT=19999

#export DEBG="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5006"
docker-compose -f docker-compose-orderer-frontend-bft.yaml up -d



#./network-create-base.sh $@

#./network-update-common-dns.sh $@
