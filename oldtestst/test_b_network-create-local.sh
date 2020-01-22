#!/bin/bash

cd /home/kilpio/CodeLab/merge_test/fabric-starter
source lib/util/util.sh
source lib.sh

TEST_CHANNEL_NAME='testlocal'$RANDOM
CHAINCODE_NAME=${CHAINCODE_NAME:-reference}
DEBUG=${DEBUG:-false}
first_org=${1:-org1}
second_org=${2:-org2}


export DOMAIN=${DOMAIN:-example.com}
export ORG=${ORG:-$first_org}
export PEER0_PORT=${PEER0_PORT:7051}

if [ "$DEBUG" = "false" ]; then
    output='/dev/null'
else
    output='/dev/stdout'
fi

# Check if orgs been created, channel common has been created, chaincode has been instantiated.



#Creating the $TEST_CHANNEL_NAME channel
./channel-create.sh $TEST_CHANNEL_NAME 2>&1 > $output

#Now check if the channel has been created.

# The `peer channel` command allows administrators to perform channel related operations on a peer,
# such as joining a channel or listing the channels to which a peer is joined.


result=`docker exec cli.$ORG.$DOMAIN /bin/bash -c \
'source container-scripts/lib/container-lib.sh; \
       peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS -c '$TEST_CHANNEL_NAME' $ORDERER_TLSCA_CERT_OPTS 2>/dev/null | \
       configtxlator  proto_decode --type "common.Block" | \
jq .data.data[0].payload.data.last_update.payload.header.channel_header.channel_id' | \
sed -E -e 's/\"|\n|\r//g'`


if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
    echo
    printYellow "OK: Test channel <$TEST_CHANNEL_NAME> created."
    
else
    echo
    printError "ERROR: Creating channel <$TEST_CHANNEL_NAME> failed!"
    printError "See logs above.                                   "
fi

#Adding second org to the $TEST_CHANNEL_NAME channel
./channel-add-org.sh $TEST_CHANNEL_NAME $second_org 2>&1 > $output



result=`docker exec cli.$ORG.$DOMAIN /bin/bash -c \
'source container-scripts/lib/container-lib.sh; \
       peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS -c '$TEST_CHANNEL_NAME' $ORDERER_TLSCA_CERT_OPTS 2>/dev/null | \
       configtxlator  proto_decode --type common.Block | \
jq .data.data[0].payload.data.config.channel_group.groups.Application.groups.'$second_org'.values.MSP.value.config.name' | \
sed -E -e 's/\"|\n|\r//g'`

#
if [ "$result" = "$second_org" ]; then
    echo
    printYellow "OK: <$result> has been added to the <$TEST_CHANNEL_NAME> channel."
else
    echo
    printError "ERROR: failed to add <$second_org> to the <$TEST_CHANNEL_NAME> channel!"
    printError "See logs above.                                   "
fi



orgs=("$first_org" "$second_org")
current_peer0_port=7051

for current_org in ${orgs[*]}; do
    
    PEER0_PORT=$current_peer0_port ORG="$current_org" ./channel-join.sh $TEST_CHANNEL_NAME 2>&1 > $output
    
    current_peer0_port=$((current_peer0_port + 1000))
    
    result=`docker exec cli.$current_org.$DOMAIN /bin/bash -c \
    'source container-scripts/lib/container-lib.sh; \
        peer channel list -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS 2>/dev/null |\
    grep -E "^'$TEST_CHANNEL_NAME'$"'`
    
    if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
        echo
        printYellow "OK: <$current_org> sucsessfuly joined the <$TEST_CHANNEL_NAME> channel."
    else
        echo
        printError "ERROR: <$current_org> failed to join the <$TEST_CHANNEL_NAME> channel!"
        printError "See logs above.                                   "
    fi
done

# The `peer chaincode install` command allows administrators to install chaincode onto the filesystem of a peer.
# The `peer chaincode instantiate` command allows administrators to instantiate chaincode on a channel of which the peer is a member.


#Instantiating the $CHAINCODE_NAME chaincode on the $TEST_CHANNEL_NAME channel
PEER0_PORT=7051 ORG=org1 ./chaincode-instantiate.sh $TEST_CHANNEL_NAME $CHAINCODE_NAME  2>&1 > $output

#Wait for the chaincode to instantiate
sleep 5


#Check if the chaincode been instantiated for both peers
orgs=("$first_org" "$second_org")
current_peer0_port=7051

for current_org in ${orgs[*]}; do
    
    current_peer0_port=$((current_peer0_port + 1000))
    result=`docker exec cli.$current_org.$DOMAIN /bin/bash -c \
    'source container-scripts/lib/container-lib.sh; \
    peer chaincode list --instantiated -C '$TEST_CHANNEL_NAME' -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS 2>/dev/null' | \
    tail -n+2 | cut -d ':' -f 2 | cut -d ',' -f 1 | sed -Ee 's/ |\n|\r//g'`
    
    if [ "$result" = "$CHAINCODE_NAME" ]; then
        echo
        printYellow "OK: $current_org reports the <$CHAINCODE_NAME> chaincode is sucsessfuly instantiated on the <$TEST_CHANNEL_NAME> channel."
    else
        echo
        printError "ERROR: $current_org reports the <$CHAINCODE_NAME> chaincode failed to instantiate on the <$TEST_CHANNEL_NAME> channel."
        printError "See logs above."
    fi
done



#testing put/query operations with $CHAINCODE_NAME chaincode

#put from $first_org
PEER0_PORT=7051 ORG=org1 ./chaincode-invoke.sh $TEST_CHANNEL_NAME $CHAINCODE_NAME '["put","'$TEST_CHANNEL_NAME'","'$TEST_CHANNEL_NAME'"]' 2>&1 > $output
sleep 5
#query from $second_org
PEER0_PORT=8051 ORG=org2 ./chaincode-query.sh $TEST_CHANNEL_NAME $CHAINCODE_NAME '["get","'$TEST_CHANNEL_NAME'"]' 2>&1 | tee /tmp/$TEST_CHANNEL_NAME 2>&1 > $output


result=`tail -1 /tmp/$TEST_CHANNEL_NAME | sed -e 's/\n//g' -e 's/\r//g'`
rm /tmp/$TEST_CHANNEL_NAME

if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
    echo
    printYellow "OK: put <$TEST_CHANNEL_NAME>, got <$result> as expected."
else
    echo
    printError "ERROR: put <$TEST_CHANNEL_NAME>, got <$result>!"
    printError "See logs above."
fi

