const shim = require('fabric-shim');
const Chaincode = require('./chaincode-dns');

shim.start(new Chaincode());