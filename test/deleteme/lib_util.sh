#!/usr/bin/env bash


BASEDIR=$(dirname $0)
CURRENT_DIR=$(pwd)


FULL_PATH=$(pwd)


# Do not be too much verbose
DEBUG=${DEBUG:-true}
if [[ "$DEBUG" = "false" ]]; then
    output='/dev/null'
else
    output='/dev/stdout'
fi
export output



printDbg() {
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${TEST_LAUNCH_DIR}/fs_network_test.log"}}

	if [[ "$DEBUG" = "false" ]]; then
	    outputdev=/dev/null
	else 
	    outputdev=/dev/stdout
	fi

	if (( $# == 0 )) ; then
	while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE} > ${outputdev}
        done
#	echo $(cat < /dev/stdin) | tee -a ${FSTEST_LOG_FILE} > ${outputdev}
	else
	echo "$@" | tee -a ${FSTEST_LOG_FILE} > ${outputdev}
	fi 
}

printLog() {
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${TEST_LAUNCH_DIR}/fs_network_test.log"}}

	if (( $# == 0 )) ; then
	    while read -r line ; do
        	echo "${line}" | cat >> ${FSTEST_LOG_FILE} 
            done
	else
		echo "$@" | cat >> ${FSTEST_LOG_FILE}
	fi 
}

printToLogAndToScreen() {
	if (( $# == 0 )) ; then
		while read -r line ; do
    		    echo "${line}" | tee -a ${FSTEST_LOG_FILE}
		done
	else
	echo "$@" | tee -a ${FSTEST_LOG_FILE}
	fi 
}



curlItGet()
{
local url=$1
local cdata=$2
local wtoken=$3

    res=$(curl -sw "%{http_code}"  "${url}" -d "${cdata}" -H "Content-Type: application/json" -H "Authorization: Bearer ${wtoken}")
    http_code="${res:${#res}-3}"
    if [ ${#res} -eq 3 ]; then
      body=""
    else
      body="${res:0:${#res}-3}"
    fi
    jwt=$(echo ${body}) 
    echo "$jwt $http_code"
}

function generateMultipartBoudary() {
    echo -n -e "--FabricStarterTestBoundary"$(date | md5sum | head -c 10)
}

function generateMultipartHeader() {
multipart_header='----'${1}'\r\nContent-Disposition: form-data; name="file"; filename="'
multipart_header+=${2}'"\r\nContent-Type: "application/zip"\r\n\r\n'
echo -n -e  ${multipart_header}
}

function generateMultipartTail() {
boundary=${1}

multipart_tail='\r\n\r\n----'
multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="targets"\r\n\r\n\r\n----'
multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="version"\r\n\r\n1.0\r\n----'
multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="language"\r\n\r\nnode\r\n----'
multipart_tail+=${boundary}'--\r\n'
echo -n -e ${multipart_tail}
}





