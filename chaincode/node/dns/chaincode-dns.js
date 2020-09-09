const StorageChaincode = require('chaincode-node-storage');
const shim = require('fabric-shim');
const _ = require('lodash');

const logger = shim.newLogger('DnsChaincode');

module.exports = class DnsChaincode extends StorageChaincode {

    async registerOrgByParams(args) {
        if (args.length < 5) {
            throw new Error('incorrect number of arguments: orgId, domain, orgIp, peer0Port, wwwPort params are required');
        }
        const orgObj = {
            orgId: _.get(args, "[0]"),
            domain: _.get(args, "[1]"),
            orgIp: _.get(args, "[2]"),
            peer0Port: _.get(args, "[3]"),
            wwwPort: _.get(args, "[4]")
        }
        logger.info("Org object got by params", JSON.stringify(orgObj));
        return this.registerOrg([JSON.stringify(orgObj)]);
    }

    async registerOrg(args) {
        if (args.length < 1) {
            throw new Error('incorrect number of arguments, Org object is required');
        }
        const orgObj = JSON.parse(_.get(args, "[0]"));
        const orgId = _.get(orgObj, "orgId");
        const orgDomain = _.get(orgObj, "domain");
        const peer0Port = _.get(orgObj, "peer0Port");

        if (!(orgId && orgDomain && peer0Port)) {
            throw new Error('orgId, domain and peer0Port properties are required');
        }
        const orgNameDomain=`${orgId}.${orgDomain}`;
        if (orgObj.orgIp) {
            await this.updateRegistryObject("dns", this.dnsUpdater(orgObj.orgIp, `www.${orgNameDomain} peer0.${orgNameDomain}`));
        }
        return this.updateRegistryObject("orgs", {[orgNameDomain]:orgObj});
    }

    async registerOrdererByParams(args) {
        if (args.length < 5) {
            throw new Error('incorrect number of arguments: ordererName, domain, ordererPort, ordererIp, wwwPort params are required');
        }
        const ordererObj = {
            ordererName: _.get(args, "[0]"),
            domain: _.get(args, "[1]"),
            ordererPort: _.get(args, "[2]"),
            ordererIp: _.get(args, "[3]"),
            wwwPort: _.get(args, "[4]")
        }
        logger.info("Orderer object got by params", JSON.stringify(ordererObj));
        return this.registerOrderer([JSON.stringify(ordererObj)]);
    }

    async registerOrderer(args) {
        if (args.length < 1) {
            throw new Error('incorrect number of arguments, Orderer object is required');
        }
        const ordererObj = JSON.parse(_.get(args, "[0]"));

        const ordererName = _.get(ordererObj, "ordererName");
        const ordererDomain = _.get(ordererObj, "domain");
        const ordererPort = _.get(ordererObj, "ordererPort");

        if (!(ordererName && ordererDomain && ordererDomain)) {
            throw new Error('ordererName, domain and ordererPort properties are required');
        }

        if (ordererObj.ordererIp) {
            await this.updateRegistryObject("dns", this.dnsUpdater(ordererObj.ordererIp,
                `${ordererName}.${ordererDomain} www.${ordererDomain} www.${ordererName}.${ordererDomain}`));
        }

        return this.updateRegistryObject("osn", {[`${ordererName}.${ordererDomain}:${ordererPort}`]: ordererObj});
    }

    async updateRegistryObject(dataKey, newData) {
        let data = await this.get([dataKey]);
        try {
            data = JSON.parse(data);
            logger.debug(`${dataKey} Old Value: `, data);
        } catch (err) {
            data = {};
        }
        typeof newData === "function"
            ? newData(data)
            : _.assign(data, newData);

        const dataStringified = JSON.stringify(data);

        logger.debug(`Updating ${dataKey} record with `, dataStringified);
        return this.put([dataKey, dataStringified]);
    }


    dnsUpdater(ip, newDnsNames) {
        return (oldDnsInfo) => {
            oldDnsInfo[ip] = (oldDnsInfo[ip] || '') + (oldDnsInfo[ip] ? ' '  : '') + newDnsNames;
            return oldDnsInfo;
        };
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
