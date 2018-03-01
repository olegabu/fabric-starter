export IP_ORDERER=172.18.0.3

./network.sh -m down
docker ps -a

./network.sh -m generate-peer -o a -a 4000 -w 8081
./network.sh -m generate-orderer -o a
./network.sh -m up-orderer

./network.sh -m up-one-org -o a -k common
./network.sh -m update-sign-policy -o a -k common


