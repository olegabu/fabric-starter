const shim = require('fabric-shim');
const Chaincode = require('./chaincode-reference1');

shim.start(new Chaincode());