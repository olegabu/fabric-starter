#!/bin/bash


function exit_test() {
[ 1 = 2 ] 
#&& exit 0 || exit 1
}


function exit_code_print() {
exit_test
echo $?
}

exit_code_print


