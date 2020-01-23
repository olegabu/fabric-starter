#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh

ORG=${2:-${ORG}}
ORG=${ORG:-org1}

export ORG
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}


CHAINCODE_ZIP_PATH=${1:-${CHAINCODE_ZIP_PATH}} 
printInColor "1;36" "Installing ${CHAINCODE_ZIP_PATH} chaincode on ${ORG}.${DOMAIN} using API..." | printDbg


api_ip=$(getAPIHost ${ORG} ${DOMAIN})
api_port=$(getAPIPort ${ORG} ${DOMAIN})

read jwt jwt_http_code < <(curlItGet "http://${api_ip}:${api_port}/users" "{\"username\":\"${API_USERNAME:-user4}\",\"password\":\"${API_PASSWORD:-passw}\"}"; echo)
jwt=$(echo $jwt | tr -d '"')

if [[ "$jwt_http_code" -eq 200 ]]; then
    printGreen "\nOK: JWT token obtained." | printDbg
else
    printError "\nERROR: Can not authorize. Failed to get JWT token!\nSee ${FSTEST_LOG_FILE} for logs." | printDbg
    exit 1
fi


function multipartBoudary() {
echo -n -e "--FabricStarterTestBoundary"$(date | md5sum | head -c 10)
}


filepath=${CHAINCODE_ZIP_PATH}
filename=$(basename $filepath)
boundary=$(multipartBoudary)

multipart_header='----'${boundary}'\r\nContent-Disposition: form-data; name="file"; filename="'
multipart_header+=${filename}'"\r\nContent-Type: "application/zip"\r\n\r\n'

multipart_tail='\r\n\r\n----'
multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="targets"\r\n\r\n\r\n----'
multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="version"\r\n\r\n1.0\r\n----'
multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="language"\r\n\r\nnode\r\n----'
multipart_tail+=${boundary}'--\r\n'

TMP_OUT_FILE=$(tempfile); trap "rm -f ${TMP_OUT_FILE}" EXIT;

#
echo -n -e ${multipart_header} > "${TMP_OUT_FILE}"
cat   ${filepath} >> "${TMP_OUT_FILE}"
echo -n -e ${multipart_tail} >> "${TMP_OUT_FILE}"
#

read reply_code reply_text < <(\
res=$(curl http://${api_ip}:${api_port}/chaincodes ${verbose} -sw "%{http_code}"\
 -H "Authorization: Bearer ${jwt}" \
 -H 'Content-Type: multipart/form-data; boundary=--'${boundary} \
 --data-binary @"${TMP_OUT_FILE}" 2>/dev/null)

res=$(echo "$res" | tr -d '\n' | tr -d '\r')
http_code="${res:${#res}-3}"

if [ ${#res} -eq 3 ]; then
  body=""
else
  body="${res:0:${#res}-3}"
fi
text=$(echo ${body}) 
    echo "$http_code $text"
)

echo ${reply_code}

printDbg ${reply_text}

if [[ "$reply_code" -eq "200" ]]; then
    printGreen "\nOK: ${CHAINCODE_ZIP_PATH} installed to ${ORG}" | printDbg
    exit 0
else
    printError "\nERROR: installing ${CHAINCODE_ZIP_PATH} on ${ORG} failed!\nSee ${FSTEST_LOG_FILE} for logs." | printDbg
    exit 1
fi

exit























echo -n -e '------WebKitFormBoundaryyVdQXIeSz4e0UIAp\r\nContent-Disposition: form-data; name="file"; filename="reference7.zip"\r\nContent-Type: "application/zip"\r\n\r\n' > out.bin
cat reference7.zip >> out.bin
echo -n -e '\r\n\r\n------WebKitFormBoundaryyVdQXIeSz4e0UIAp\r\nContent-Disposition: form-data; name="targets"\r\n\r\n\r\n------WebKitFormBoundaryyVdQXIeSz4e0UIAp\r\nContent-Disposition: form-data; name="version"\r\n\r\n1.0\r\n------WebKitFormBoundaryyVdQXIeSz4e0UIAp\r\nContent-Disposition: form-data; name="language"\r\n\r\nnode\r\n------WebKitFormBoundaryyVdQXIeSz4e0UIAp--\r\n' >> out.bin

curl http://${api_ip}:${api_port}/chaincodes -v -H "Authorization: Bearer ${jwt}" \
-H 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryyVdQXIeSz4e0UIAp' \
--data-binary @out.bin

exit

read reply_text reply_code < <(curlItGet  "http://${api_ip}:${api_port}/chaincodes" "{\"channelId\":\"${TEST_CHANNEL_NAME}\",\"file\":\"reference7.zip\",\"targets\":\"peer0.org1.example.com\"}" "${jwt}";echo)
#read reply_text reply_code < <(curlItGet  "http://${api_ip}:${api_port}/channels/${TEST_CHANNEL_NAME}" "{\"channelId\":\"${TEST_CHANNEL_NAME}\",\"waitForTransactionEvent\":true}" "${jwt}";echo)

echo "$reply_code"

exit
if [[ "$reply_code" -eq 200 ]]; then
    printGreen "\nOK: ${ORG} joined to ${TEST_CHANNEL_NAME} channel" | printDbg
    exit 0
else
    printError "\nERROR: joining ${ORG} to ${TEST_CHANNEL_NAME} failed!\nSee ${FSTEST_LOG_FILE} for logs." | printDbg
    exit 1
fi


exit




















BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh


: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}

TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}}

ORG=${ORG:-org1}
DOMAIN=${DOMAIN:-example.com} 

CHAINCODE_PREFIX=${CHAINCODE_PREFIX:-reference}


printInColor "1;36" "$ORG (Port:$PEER0_PORT) Installing the <${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}> chaincode on the cli.${ORG}.${DOMAIN} machine using API..." | printDBG


docker exec -i cli.${ORG}.${DOMAIN} sh -c "mkdir /opt/chaincode/node/${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME} ; cp -R /opt/chaincode/node/reference/* \
                                           /opt/chaincode/node/${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}"  2>&1 | printDbg
docker exec -i cli.${ORG}.${DOMAIN} sh -c "./container-scripts/network/chaincode-install.sh ${CHAINCODE_PREFIX}${TEST_CHANNEL_NAME}" 2>&1 | printDbg

exit


#echo "(cd ${BASEDIR}/.. && PEER0_PORT=$PEER0_PORT ORG=$ORG ./chaincode-instantiate.sh $TEST_CHANNEL_NAME $CHAINCODE_NAME | tee -a $FSTEST_LOG_FILE > "${output}")"
(cd ${FABRIC_DIR} && PEER0_PORT=${PEER0_PORT} ORG=${ORG} ./chaincode-instantiate.sh ${TEST_CHANNEL_NAME} ${CHAINCODE_NAME} | tee -a ${FSTEST_LOG_FILE} > "${output}")

#Wait for the chaincode to instantiate
sleep 5

    result=$(docker exec cli.${ORG}.${DOMAIN} /bin/bash -c \
        'source container-scripts/lib/container-lib.sh; \
        peer chaincode list --instantiated -C '${TEST_CHANNEL_NAME}' -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS 2>/dev/null' |
        tail -n+2 | cut -d ':' -f 2 | cut -d ',' -f 1 | sed -Ee 's/ |\n|\r//g')

    if [ "$result" = "$CHAINCODE_NAME" ]; then
        
        printGreen "OK: $ORG reports the <$CHAINCODE_NAME> chaincode is successfully instantiated on the <$TEST_CHANNEL_NAME> channel."
        exit 0
    else
        
        printError "ERROR: $ORG reports the <$CHAINCODE_NAME> chaincode failed to instantiate on the <$TEST_CHANNEL_NAME> channel."
        printError "See logs above."
        exit 1
    fi
