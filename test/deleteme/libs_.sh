function echoMultiline() {

    set -f
    IFS=
    echo ${result} 
    set +f
}    





# function multilineToCSV(){

#     echo ${1} | awk -vORS=, '{ print $2 }' | sed 's/,$/\n/'
# }

# function getFabricTestContainersList() {
#     local org=${1}
#     local domain=${2}

#     local result=$(getContainersList ${org}) #| egrep "${egrep_regex_filter}" | grep -v "${grep_not_regex_filter}" | grep "${domain}")

#     echoMultiline ${result} | printDbg
#     #print list in csv format
#     echo "${result[@]}" | awk -vORS=, '{ print $2 }' | sed 's/,$/\n/' 
# }


# function addDomain() {
#     local domain=${1}
#     local csv_container_list=${2}

#     echo ${csv_container_list} | sed -e "s/,/.${domain},/g" -e "s/$/.${domain}/"
# }

# function addOrgDomain() {
#     local org=${1}
#     local domain=${2}
#     local csv_container_list=${3}

#     echo ${csv_container_list} | sed -e "s/,/.${org}.${domain},/g" -e "s/$/.${org}.${domain}/"
# }


# function compareOrdererContainersLists() {
# compareContainersLists ${1} ${2} $(addDomain ${2} ${3})
# }


# function compareOrgContainersLists() {
# compareContainersLists ${1} ${2} $(addOrgDomain ${1} ${2} ${3})
# }


# function compareCSVLists() {
#     local list1=${1} #running containers
#     local list2=${2} #containers that should be up

#     local is_different=$(comm -1 -3 <(echo $list1 | tr ',' '\n'|sort) <(echo $list2 | tr ',' '\n'|sort) | wc -w)

#     printDbg $is_different
#     setExitCode [ "${is_different}" = "0" ]
# }



# function compareContainersLists() {
#     local org=${1}
#     local domain=${2}
#     local csv_container_list=${3}
#     compareCSVLists $(getFabricTestContainersList $org $domain)  ${csv_container_list}
# }
