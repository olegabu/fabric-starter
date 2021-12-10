const shim = require('fabric-shim');
const Chaincode = require('./chaincode-dns');

if ( process.env.EXTERNAL ) {
    console.log(`Chaincode EXTERNAL start. PACKAGE_ID: ${process.env.PACKAGE_ID}, address: ${process.env.ADDRESS}`);
    const server = shim.server(new Chaincode(), {
        ccid: process.env.PACKAGE_ID,
        address: process.env.ADDRESS
    });
    server.start()
} else {
    console.log("Chaincode SHIM start");
    shim.start(new Chaincode());
}