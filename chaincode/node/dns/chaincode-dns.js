const StorageChaincode = require('chaincode-node-storage');
const shim = require('fabric-shim');

const logger = shim.newLogger('DnsChaincode');

module.exports = class DnsChaincode extends StorageChaincode {

    async registerOrg(args) {
        let req = this.toKeyValue(this.stub, args);

        let orgNameDomain = req.key;
        let orgIp = req.value;

        let wwwAddr = `www.${orgNameDomain}`;
        let peerAddr = `peer0.${orgNameDomain}`;

        let dnsNames = await this.stub.getState(orgIp); //await this.get(["${orgIp}"]);
        logger.debug(`DNS record before update ${orgIp} `, dnsNames);

        dnsNames=`${dnsNames} ${wwwAddr} ${peerAddr}`;

        logger.debug(`Updating DNS record with ${orgIp} `, dnsNames);

        let dnsArgs = [orgIp, dnsNames];

        return this.put(dnsArgs);
    }
};
