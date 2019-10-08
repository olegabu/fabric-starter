const StorageChaincode = require('chaincode-node-storage');
const shim = require('fabric-shim');
const _ = require('lodash');

const logger = shim.newLogger('DnsChaincode');

module.exports = class DnsChaincode extends StorageChaincode {

    async registerOrg(args) {
        const req = this.toKeyValue(this.stub, args);
        const orgNameDomain = req.key;
        const orgIp = req.value;
        const dnsNames = `www.${orgNameDomain} peer0.${orgNameDomain}`;

        return this.updateDns(orgIp, dnsNames);
    }

    async registerOrderer(args) {
        const ordererIp = _.get(args, "[0]");
        const ordererName = _.get(args, "[1]");
        const ordererDomain = _.get(args, "[2]");
        const ordererPort = _.get(args, "[3]");

        await this.updateDns(ordererIp, `${ordererName}.${ordererDomain} www.${ordererDomain}`);
        let osnInfo = await this.get(["osn"]);
        try {
            osnInfo = JSON.parse(osnInfo);
        } catch (err) {
            osnInfo = {};
        }
        osnInfo[`${ordererName}.${ordererDomain}:${ordererPort}`] = ordererIp;
        const osnStringified = JSON.stringify(osnInfo);

        logger.debug('Updating OSN record with ', osnStringified);
        return this.put(['osn', osnStringified]);
    }

    async updateDns(ip, dnsNames) {
        let dnsInfo = await this.get(['dns']);
        logger.debug('DNS Info ', dnsInfo);
        try {
            dnsInfo = JSON.parse(dnsInfo);
        } catch (err) {
            dnsInfo = {};
        }
        dnsInfo[ip] = `${dnsInfo[ip] || ''} ${dnsNames}`;
        const dnsStringified = JSON.stringify(dnsInfo);
        logger.debug('Updating DNS record with ', dnsStringified);
        return this.put(['dns', dnsStringified]);
    }
};
