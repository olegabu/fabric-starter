#!/usr/bin/env zsh
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0)

function arrayStart() {
    local a=(1 0)
    echo ${a[1]}
}

a=(1 0)
echo (0 1)
echo ${a[1]}


timeNowSecondsEpoch=`date +%s`


sleep 100




a="1,2,3,4,5,6,7"
b="a,b,c,d,e,f,g"

arrA=($(sed -e 's/,/ /g' <<<$a))
arrB=($(sed -e 's/,/ /g' <<<$b))


function printArr() {
local -n FIRST_ARR=$1
local -n SECOND_ARR=$2


echo ${FIRST_ARR[1]}
echo ${SECOND_ARR[2]}

}

printArr arrA arrB
