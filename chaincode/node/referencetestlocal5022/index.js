const shim = require('fabric-shim');
const Chaincode = require('./chaincode-reference');

shim.start(new Chaincode());