#!/usr/bin/env bash


function main() {
    rm -rf tls-orderer tls-org1

    generateRootTlsCert 'tls-orderer/tls-root' example.com tlsca.example.com
    generateRootTlsCert 'tls-org1/tls-root' org1.example.com tlsca.org1.example.com

#    generateRootTlsCert 'tls-orderer/tls' example.com orderer.example.com v3_tls
#    generateRootTlsCert 'tls-org1/tls' org1.example.com peer0.org1.example.com v3_tls

    signCert 'tls-orderer' orderer.example.com orderer
    signCert 'tls-org1' peer0.org1.example.com peer0

    #openssl req -config openssl.cnf \
    #      -key private/ca.key.pem \
    #      -new -x509 -days 7300 -sha256 -extensions v3_ca \
    #      -out certs/ca.cert.pem


}

function generateRootTlsCert() {

    local path=${1:?path required}
    local org=${2:?org required}
    local cnName=${3:?cn required}

    mkdir -p ${path}
    export CERT_COMMON_NAME=${cnName}
    export ORG=${org}

#    openssl ecparam -genkey -name prime256v1 -out ${path}/server.key

#     openssl req -new -sha256 -key ${path}/server.key \
#        -x509 -sha256 -days 365 \
#        -config ./tlsca-csr.conf \
#        -extensions v3_ca \
#        -out ${path}/server.crt

    openssl req \
       -newkey rsa:2048 -nodes -keyout ${path}/server.key \
       -x509 -sha256 -days 365 \
       -config ./tlsca-csr.conf \
       -extensions v3_ca \
       -out ${path}/server.crt

}

function signCert() {

    local entityPath=${1:?entityPath required}
    local cnName=${2:?cn required}

    export ORG=${3:?org required}
    export CERT_COMMON_NAME=${cnName}

    mkdir -p ${entityPath}/tls

    openssl req -nodes -newkey rsa:2048 -keyout ${entityPath}/tls/server.key -out ${entityPath}/server.csr \
        -subj "/C=US/ST=California/L=San Francisco/CN=${cnName}"
set -x
#    openssl ecparam -genkey -name prime256v1 -out ${entityPath}/tls/server.key

#    openssl req -new -sha256 -key ${entityPath}/tls/server.key -nodes \
#        -subj "/C=US/ST=California/L=San Francisco/CN=${cnName}" \
#        -out ${entityPath}/server.csr


    openssl x509 -sha256 -days 365 -req -in ${entityPath}/server.csr \
        -CA ${entityPath}/tls-root/server.crt \
        -CAkey ${entityPath}/tls-root/server.key \
        -CAcreateserial \
        -extfile ./tlsca-csr.conf  \
        -extensions v3_tls \
        -out ${entityPath}/tls/server.crt
set +x
}

main


