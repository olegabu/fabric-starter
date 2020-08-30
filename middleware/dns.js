// when adding a new org:
// ./chaincode-invoke.sh common dns '["put","192.168.99.102","peer0.org2.example.com www.org2.example.com"]'
// verify ip was added to hosts file and the name is now resolvable
// docker exec api.org1.example.com wget peer0.org2.example.com

module.exports = async (app, _fabricStarterClient, eventBus) => {
    const fs = require('fs');
    const _ = require('lodash');
    const logger = require('log4js').getLogger('dns');
    const jwt = require('jsonwebtoken');

    const FabricStarterClient = require('../fabric-starter-client');
    const fabricStarterClient = new FabricStarterClient();
    const fabricCLI = require('../fabric-cli');
    const util = require('../util');
    const cfg = require('../config.js');
    const certsManager = require('../certs-manager');

    const NODE_HOSTS_FILE = '/etc/hosts';
    const ORDERER_HOSTS_FILE = '/etc/hosts_orderer';

    const channel = process.env.DNS_CHANNEL || 'common';
    const chaincodeName = process.env.DNS_CHAINCODE || 'dns';
    const username = process.env.DNS_USERNAME || 'serviceUser';
    const password = process.env.DNS_PASSWORD || 'servicePass';
    // const skip = !process.env.MULTIHOST;
    const period = process.env.DNS_PERIOD || 60000;
    const orgDomain = `${process.env.ORG}.${process.env.DOMAIN}`;
    const MY_IP = process.env.MY_IP;
    const ordererDomain = process.env.ORDERER_DOMAIN || process.env.DOMAIN;
    const queryTarget = process.env.DNS_QUERY_TARGET || `peer0.${orgDomain}:${process.env.PEER0_PORT || 7051}`;


    let blockListenerStarted = false;
    let inProcess = false;
    logger.info('started');

    let taskSettings = {};
    let orgs = {};

    app.get("/settings/tasks", (req, res) => {
        res.json(taskSettings);
    });

    app.post("/settings/tasks", (req, res) => {
        logger.info('Saving tasks');

        taskSettings = req.body;
        // eventBus.emit('orgs-configuration-changed', orgs);
        // eventBus.emit('osn-configuration-changed');
        // const dnsResponses = await fabricStarterClient.query(channel, chaincodeName, 'get', '["dns"]', {targets: queryTarget});
        res.status(200).send("");
    });


    setInterval(async () => {
        logger.info(`periodically query every ${period} msec for dns entries and update ${NODE_HOSTS_FILE}`);
        try {
            await processEvent();
        } catch (e) {
            logger.error("setInterval error", e);
        }
    }, period);

    await processEvent();

    async function processEvent() {
        // if (skip) {
        //     logger.info('Skipping dns track as not MULTIHOST');
        //     return;
        // }

        if (!blockListenerStarted) {
            try {
                await login();
                await startBlockListener();
                blockListenerStarted = true;
            } catch (e) {
                logger.warn("Can't start DNS block listener", e);
                return;
            }
        }

        if (inProcess) {
            return;
        }
        inProcess = true;
        try {
            let dnsRecords = await getChaincodeData("dns");
            if (dnsRecords) {
                dnsRecords = filterOutByIp(dnsRecords, MY_IP);
                util.writeFile(NODE_HOSTS_FILE, dnsRecords);
                util.writeFile(ORDERER_HOSTS_FILE, dnsRecords);
            }

            const osns = await getChaincodeData("osn");
            if (osns) {
                _.forEach(osns, async (osn, osnKey) => {
                    let ordererWwwPort = osn.wwwPort || cfg.ORDERER_WWW_PORT;
                    try {
                        await util.checkRemotePort(`www.${osn.ordererDomain}`, ordererWwwPort);
                        await fabricCLI.downloadOrdererMSP(ordererWwwPort, osn.ordererDomain);
                    } catch (e) {
                        logger.error(`Remote port is inaccessible www.${osn.ordererDomain}:${ordererWwwPort}`, e);
                    }
                });
                eventBus && eventBus.emit('osn-configuration-changed', osns);
            }

            const chainOrgs = await getChaincodeData("orgs");
            if (chainOrgs) {
                orgs = _.merge(orgs, chainOrgs);
                // eventBus.emit('orgs-configuration-changed', orgs);
                // eventBus.emit('osn-configuration-changed', osns);
            }


            // taskSettigns=await getChaincodeData("tasksSettings") ||{};
        } finally {
            inProcess = false;
        }
    }

    async function login() {
        await fabricStarterClient.init();
        await fabricStarterClient.loginOrRegister(username, password);

        logger.info(`logged in as ${username}`);
    }


    async function startBlockListener() {
        logger.info(`logged in as ${username}`);

        logger.info(`Trying to start DNS block listener on channel ${channel}`);
        await fabricStarterClient.registerBlockEvent(channel, async block => {
            logger.debug(`block ${block.number} on ${block.channel_id}`);
            await processEvent();
        }, e => {
            throw new Error(e);
        });
    }

    async function getChaincodeData(dataKey) {
        let result = null;
        const dataResponses = await fabricStarterClient.query(channel, chaincodeName, 'get', `["${dataKey}"]`, {targets: queryTarget});
        logger.debug(`dataResponses for ${dataKey}`, dataResponses);
        try {
            if (dataResponses && dataResponses[0] !== '') {
                result = JSON.parse(dataResponses);
            }
        } catch (e) {
            logger.warn(`Can't parse chaincode data record: ${dataResponses}`, e);
        }
        return result;
    }

    function filterOutByIp(list, excludeIp) {
        delete list[excludeIp];
        return list;
    }
};
