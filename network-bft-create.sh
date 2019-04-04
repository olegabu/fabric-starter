#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh

: ${SYSTEM_CHANNEL_ID:=bftchannel}

function envSubstConfigs {
    local org=${1:?-Org must be specified}
    local kind=${2:?-"orderer" or "frontend" must be specified}
    local ordererNodesHostsConfigList=${3:?-"ordererNodesHostsConfigList" must be specified}
    local orderingNodeId=${4:?-"orderingNodeId" must be specified}
    local ordererNodesIdsList=${5:?-"ordererNodesIdsList" must be specified}

    local orgConfigPath=crypto-config/bft/${org}-${kind}
    mkdir -p ${orgConfigPath}
    cp -r templates/bft/config ${orgConfigPath}
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
            mspPath=crypto-config/ordererOrganizations/${DOMAIN}/orderers/${kind}.${orgFrom}.${DOMAIN}/msp
            docker-compose -f docker-compose-util.yaml run --rm cli.bft cp ${mspPath}/keystore/`ls ${mspPath}/keystore/` "crypto-config/bft/${orgFrom}-${kind}/config/keys/keystore.pem"
            for orgTo in ${orgs}; do
                local idPropertyName="${kind}NodeId"
#                cp -r ${mspPath}/tlscacerts/tlsca.${DOMAIN}-cert.pem "crypto-config/bft/${orgTo}-orderer/config/keys/cert${!idPropertyName}.pem"
#                cp -r ${mspPath}/tlscacerts/tlsca.${DOMAIN}-cert.pem "crypto-config/bft/${orgTo}-frontend/config/keys/cert${!idPropertyName}.pem"
                cp -r ${mspPath}/signcerts/${kind}.${orgFrom}.${DOMAIN}-cert.pem "crypto-config/bft/${orgTo}-orderer/config/keys/cert${!idPropertyName}.pem"
                cp -r ${mspPath}/signcerts/${kind}.${orgFrom}.${DOMAIN}-cert.pem "crypto-config/bft/${orgTo}-frontend/config/keys/cert${!idPropertyName}.pem"
            done
        done
        ordererNodeId=$((ordererNodeId +1))
        frontendNodeId=$((frontendNodeId +1))
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
    for org in ${orgs}; do
        ordererNodesHostsConfigList="$ordererNodesHostsConfigList\n${ordererNodeId} orderer.${org}.${DOMAIN} 11000"
        ordererNodesIdsList="${ordererNodesIdsList}${ordererNodesIdsList+,}${ordererNodeId}"
        frontendIdsList="$frontendIdsList${frontentNodeId},"
        frontendAddressesList="${frontendAddressesList}${frontendAddressesList+,}frontend.${org}.${DOMAIN}"
        ordererNodeId=$((ordererNodeId + 1))
        frontentNodeId=$((frontentNodeId + 1))
    done


    for org in ${orgs}; do

        envSubstConfigs $org orderer "$ordererNodesHostsConfigList" "$ordererNodeId" "$ordererNodesIdsList"
        envSubstConfigs $org frontend "$ordererNodesHostsConfigList" "$ordererNodeId" "$ordererNodesIdsList"

        export ORG=$org
        envsubst < templates/bft/cryptogen-orderer-bft-template.yaml > crypto-config/bft/cryptogen-orderer-bft.yaml
        docker-compose -f docker-compose-util.yaml run --rm cli.bft cryptogen generate --config=crypto-config/bft/cryptogen-orderer-bft.yaml

        orgConfigPath=crypto-config/bft/${org}-frontend
        mkdir -p "${orgConfigPath}/fabric"
        docker-compose -f docker-compose-util.yaml run --rm cli.bft cp -r "crypto-config/ordererOrganizations/${DOMAIN}/orderers/orderer.${org}.${DOMAIN}/msp" "${orgConfigPath}/fabric"
        envsubst <"templates/bft/orderer-frontend/orderer.yaml" >"${orgConfigPath}/fabric/orderer.yaml"

    done

    copyKeys "${orgs}"

fi

./clean.sh keepCrypto


export ORDERER_FRONTEND_ADDRESSES=$frontendAddressesList
envsubst < "templates/configtx-template.yaml" > "crypto-config/configtx.yaml"
mkdir -p crypto-config/config
docker-compose -f docker-compose-util.yaml run --rm cli.bft configtxgen -configPath crypto-config/ -outputBlock crypto-config/config/genesisblock -profile BFTGenesis -channelID ${SYSTEM_CHANNEL_ID}


ordererNodeId=0
for org in ${orgs}; do
    cp crypto-config/config/genesisblock crypto-config/bft/${org}-orderer/config
    cp crypto-config/config/genesisblock crypto-config/bft/${org}-frontend/config

    export ORG=$org COMPOSE_PROJECT_NAME=$org ORDERER_NODE_ID=$ordererNodeId
    docker-compose -f docker-compose-orderer-bft.yaml up -d
    ordererNodeId=$((ordererNodeId + 1))
    sleep 2
done



#./network-create-base.sh $@

#./network-update-common-dns.sh $@
