// when adding a new org:
// ./chaincode-invoke.sh common dns '["put","192.168.99.102","peer0.org2.example.com www.org2.example.com"]'
// verify ip was added to hosts file and the name is now resolvable
// docker exec api.org1.example.com wget peer0.org2.example.com

module.exports = async app => {
  const logger = require('log4js').getLogger('dns');
  const FabricStarterClient = require('../fabric-starter-client');
  const fabricStarterClient = new FabricStarterClient();
  const fs = require('fs');

  const hostsFile = '/etc/hosts';

  const channel = process.env.DNS_CHANNEL || 'common';
  const username = process.env.DNS_USERNAME || 'dns';
  const password = process.env.DNS_PASSWORD || 'pass';
  const skip = !process.env.MULTIHOST;
  const period = process.env.DNS_PERIOD || 60000;
  const queryTarget = process.env.DNS_QUERY_TARGET || `peer0.${process.env.ORG}.${process.env.DOMAIN}:7051`;

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
    logger.info(`periodically query every ${period} msec for dns entries and update ${hostsFile}`);
    await processEvent();
  }, period);

  async function processEvent() {
    if(skip) {
      logger.info('skipping event');
      return;
    }

    const queryResponses = await fabricStarterClient.query(channel, 'dns', 'range', '[]', {targets: queryTarget});
    logger.debug('queryResponses', queryResponses);

    const ret = queryResponses[0];

    if(ret) {
      const list = JSON.parse(ret);

      if(!list.length) {
        logger.debug('no dns records found on chain');
      } else {
        let h = `# replaced by dns listener on ${channel}\n`;
        list.forEach(o => {
          h = h.concat(o.key, ' ', o.value, '\n');
        });

        fs.writeFile(hostsFile, h, err => {
          if(err) {
            logger.error(`cannot writeFile ${hostsFile}`, err);
          } else {
            logger.info(`wrote ${hostsFile}`, h);
          }
        });
      }
    }
  }
};
