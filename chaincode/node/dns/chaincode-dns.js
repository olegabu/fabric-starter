const StorageChaincode = require('chaincode-node-storage');

module.exports = class DnsChaincode extends StorageChaincode {

    async registerOrg(args) {
        let req = this.toKeyValue(this.stub, args);

        let orgNameDomain = req.key;
        let orgIp = req.value;

        let wwwAddr = `www.${orgNameDomain}`;
        let peerAddr = `peer0.${orgNameDomain}`;

        let dnsNames = this.get(orgIp);
        dnsNames=`${dnsNames} ${wwwAddr} ${peerAddr}`;

        let dnsArgs = [orgIp, dnsNames];

        return this.put(dnsArgs);
    }
};
