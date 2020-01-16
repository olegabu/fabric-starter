#!/usr/bin/env bash


BASEDIR=$(dirname $0)
CURRENT_DIR=$(pwd)


FULL_PATH=$(pwd)

getFabricStarterPath() {
dirname=${1}

libpath=$(realpath ${dirname}/lib.sh)


if [[ ! -f ${libpath} ]]; then
    dirname=$(realpath ${dirname}/../)
getFabricStarterPath ${dirname}
else

    if [[ $dirname != '/' ]]; then
	echo ${dirname}
    else
        echo "Run tests in fabric-starter directory!"
        exit 1
    fi
fi
}


FABRIC_DIR=$(getFabricStarterPath ${FULL_PATH})
export FABRIC_DIR


# Do not be too much verbose
DEBUG=${DEBUG:-true}
if [[ "$DEBUG" = "false" ]]; then
    output='/dev/null'
else
    output='/dev/stdout'
fi
export output



printDbg() {
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}

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
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}

	if (( $# == 0 )) ; then
	    while read -r line ; do
        	echo "${line}" | cat >> ${FSTEST_LOG_FILE} 
            done
	else
		echo "$@" | cat >> ${FSTEST_LOG_FILE}
	fi 
}

printLogScreen() {
	if (( $# == 0 )) ; then
		while read -r line ; do
    		    echo "${line}" | tee -a ${FSTEST_LOG_FILE}
		done
	else
	echo "$@" | tee -a ${FSTEST_LOG_FILE}
	fi 
}



CURRENT_DIR=$(pwd)
cd ${FABRIC_DIR} && source ./lib/util/util.sh && source ./lib.sh
cd ${CURRENT_DIR}