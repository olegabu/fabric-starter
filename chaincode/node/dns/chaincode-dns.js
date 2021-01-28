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

        if (orgIp) {
            await this.updateDns(orgIp, dnsNames);
        }
        const newOrgData={[orgNameDomain]:{'ip':orgIp}};
        return this.updateRegistryObject("orgs", newOrgData);
    }

    async registerOrderer(args) {
        const ordererName = _.get(args, "[0]");
        const ordererDomain = _.get(args, "[1]");
        const ordererPort = _.get(args, "[2]");
        const ordererIp = _.get(args, "[3]");

        if (ordererIp) {
            await this.updateDns(ordererIp, `${ordererName}.${ordererDomain} www.${ordererDomain}`);
        }

        const newOrdererData={[`${ordererName}.${ordererDomain}:${ordererPort}`]: {ordererName, ordererDomain, ordererPort, ordererIp}};
        return this.updateRegistryObject("osn", newOrdererData);
/*

        let osnInfo = await this.get(["osn"]);
        try {
            osnInfo = JSON.parse(osnInfo);
        } catch (err) {
            osnInfo = {};
        }
        osnInfo[`${ordererName}.${ordererDomain}:${ordererPort}`] = {ordererName, ordererDomain, ordererPort, ordererIp};
        const osnStringified = JSON.stringify(osnInfo);

        logger.debug('Updating OSN record with ', osnStringified);
        return this.put(['osn', osnStringified]);
*/
    }

    async updateRegistryObject(dataKey, newData){
        let data = await this.get([dataKey]);
        try {
            data = JSON.parse(data);
        } catch (err) {
            data = {};
        }
        _.assign(data, newData);

        const dataStringified = JSON.stringify(data);

        logger.debug(`Updating ${dataKey} record with `, dataStringified);
        return this.put([dataKey, dataStringified]);
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

    async Invoke(stub) {
        this.stub = stub;

        let req = stub.getFunctionAndParameters();
        this.channel = stub.getChannelID();

        // const cid = new ClientIdentity(stub);
        // logger.debug("cid.mspId=%s cid.id=%s cid.cert=%j", cid.mspId, cid.id, cid.cert);
        // // alternative method to get transaction creator org and identity
        // // const creator = stub.getCreator();
        // // logger.info("creator=%j", creator);
        //
        // this.creator = cid;
        // this.creator.org = cid.mspId.split('MSP')[0];
        //
        // logger.info("Invoke on %s by org %s user %s with %j",
        //     this.channel, this.creator.org, this.creator.cert.subject.commonName, req);
        //
        // logger.info("Invoke on %s with %j", this.channel, req);

        let method = this[req.fcn];
        if (!method) {
            return shim.error(`no method found of name: ${req.fcn}`);
        }

        method = method.bind(this);

        try {
            let ret = await method(req.params);

            if (ret && !Buffer.isBuffer(ret)) {
                logger.debug(`not buffer ret=${ret}`);
                ret = Buffer.from(ret);
            }

            return shim.success(ret);
        } catch (err) {
            logger.error(err);
            return shim.error(err);
        }
    }
};
