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

