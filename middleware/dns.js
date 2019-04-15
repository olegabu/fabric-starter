// when adding a new org:
// ./chaincode-invoke.sh common dns '["put","192.168.99.102","peer0.org2.example.com www.org2.example.com"]'
// verify ip was added to hosts file and the name is now resolvable
// docker exec api.org1.example.com wget peer0.org2.example.com

module.exports = async app => {
  const fs = require('fs');
  const _ = require('lodash');
  const logger = require('log4js').getLogger('dns');
  const FabricStarterClient = require('../fabric-starter-client');
  const fabricStarterClient = new FabricStarterClient();

  const NODE_HOSTS_FILE = '/etc/hosts';
  const ORDERER_HOSTS_FILE = '/etc/hosts_orderer';

  const channel = process.env.DNS_CHANNEL || 'common';
  const username = process.env.DNS_USERNAME || 'dns';
  const password = process.env.DNS_PASSWORD || 'pass';
  const skip = !process.env.MULTIHOST;
  const period = process.env.DNS_PERIOD || 60000;
  const orgDomain = `${process.env.ORG}.${process.env.DOMAIN}`;
  const queryTarget = process.env.DNS_QUERY_TARGET || `peer0.${orgDomain}:7051`;

  await fabricStarterClient.init();

  await fabricStarterClient.loginOrRegister(username, password);

  logger.info(`logged in as ${username}`);

  await fabricStarterClient.registerBlockEvent(channel, async block => {
    logger.debug(`block ${block.number} on ${block.channel_id}`);

    await processEvent();
  }, e => {
    logger.error('registerBlockEvent', e);
  });

  logger.info(`registered for block events on ${channel}`);

  // app.get('/block-logger', (req, res) => {
  //   res.status(200).send(`Welcome to block-logger. Channels: ${channels}`);
  // });

  logger.info('started');

  setInterval(async () => {
    logger.info(`periodically query every ${period} msec for dns entries and update ${NODE_HOSTS_FILE}`);
    await processEvent();
  }, period);

  function generateHostsRecords(list) {
    let h =`# replaced by dns listener on ${channel}\n`;
    list.forEach(o => {
      h = h.concat(o.key, ' ', o.value, '\n');
    });
    return h;
  }

  function existsAndIsFile(file) {
    try {
      fs.accessSync(file, fs.constants.W_OK);
      return fs.statSync(file).isFile()
    } catch (e) {
      logger.debug(`Cannot open file ${file}`, e);
    }
  }

  function writeFile(file, hostsFileContent) {
    if (existsAndIsFile(file)) {
      fs.writeFile(file, hostsFileContent, err => {
        if (err) {
          logger.error(`cannot writeFile ${file}`, err);
        } else {
          logger.info(`wrote ${file}`, hostsFileContent);
        }
      });
    } else {
      logger.debug(`Can't open ${file}`);
    }
  }

  function filterOutOrgByPattern(list, pattern) {
    list = list.filter(o => !_.includes(_.get(o, "value"), `${pattern}`));
    return list;
  }

  async function processEvent() {
    if(skip) {
      logger.info('skipping event');
      return;
    }

    const queryResponses = await fabricStarterClient.query(channel, 'dns', 'range', '[]', {targets: queryTarget});
    logger.debug('queryResponses', queryResponses);

    const ret = queryResponses[0];

    if(ret) {
      let list;

      try {
        list = JSON.parse(ret);
      } catch (e) {
        logger.error("Unparseable dns-records: \n", ret);
      }

      if (!list.length) {
        return logger.debug('no dns records found on chain');
      }

      list = filterOutOrgByPattern(list, `.${orgDomain}`);

      if (existsAndIsFile(ORDERER_HOSTS_FILE)) {
        list = filterOutOrgByPattern(list, `orderer.${process.env.DOMAIN}`);
      }

      let hostsFileContent = generateHostsRecords(list, orgDomain);

      writeFile(NODE_HOSTS_FILE, hostsFileContent);
      writeFile(ORDERER_HOSTS_FILE, hostsFileContent);
    }
  }
};
