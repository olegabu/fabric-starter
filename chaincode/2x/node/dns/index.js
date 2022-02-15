require('dotenv').config({path: process.env.CHAINCODE_ENV_FILE});
const shim = require('fabric-shim');
const Chaincode = require('./chaincode-dns');

if ( process.env.EXTERNAL ) {
    console.log(`Start as EXTERNAL chaincode. Env file: ${process.env.CHAINCODE_ENV_FILE} PACKAGE_ID: ${process.env.PACKAGE_ID}, bind address: ${process.env.CHAINCODE_BIND_ADDRESS}`);
    const server = shim.server(new Chaincode(), {
        ccid: process.env.PACKAGE_ID,
        address: process.env.CHAINCODE_BIND_ADDRESS
    });
    server.start()
} else {
    console.log("Chaincode SHIM start");
    shim.start(new Chaincode());
}