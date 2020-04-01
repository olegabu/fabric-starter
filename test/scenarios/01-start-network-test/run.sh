cd ../../
source ./test-env.sh ${1:-local} ${2:-example.com} ${3:-org1}  ${4:-org2}
network
scenario

