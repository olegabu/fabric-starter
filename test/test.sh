#!/usr/bin/env zsh
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0)

source ${BASEDIR}/libs.sh


#echo ${#BRIGHT}
#echo ${#GREEN}
#echo ${#NORMAL}

a=1234567890

c="${BRIGHT}${GREEN}${a}${a}${a}${NORMAL}"
c="${BRIGHT}${GREEN}${a}${a}${a}"
# echo ${#c}
# echo ${c}
# d=$(printNoColors $c)
# echo ${#d}
# echo ${d}


# function printNSpaces() {
#     local count=0 ;
#     local output=""

#     while [[ $count -lt $1 ]];
#     do output+='_';
#         let count++;
#     done
#     echo ${output//_/ }
# }


# function printPaddingSpaces() {
#     local string=$1
#     local string2=$2
#     local plain_string=$(printNoColors $string)
#     local full_length=${#string}
#     local symbol_length=${#plain_string}
#     local spaces=$(( full_length - symbol_length ))

#     echo "$(printNSpaces ${spaces})""${string2}"
# }

printPaddingSpaces "${c}" "OK"





# printNoColors
# a=123456789
# printf '%-10s %-41s %-10s\n' "${a}${a}${a}" "${a}${a}${a}" "${a}${a}${a}"
#

# printf '%-10s %-41s %-10s\n' "${a}${a}${a}" "${a}${GREEN}${a}${NORMAL}${a}" "${a}${a}${a}"