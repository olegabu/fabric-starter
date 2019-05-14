const logger = require('log4js').getLogger('dns');
const fs = require('fs');

const hostsFile = '/etc/hosts';

// when adding a new org:
// ./chaincode-invoke.sh common dns '["put","192.168.99.102","peer0.org2.example.com www.org2.example.com"]'
// verify ip was added to hosts file and the name is now resolvable
// docker exec api.org1.example.com wget peer0.org2.example.com

module.exports = async function(block, fabricStarterClient) {
  logger.debug(block);

  const queryResponses = await fabricStarterClient.query(block.channel_id, 'dns', 'range', '[]', {});
  logger.debug('queryResponses', queryResponses);

  const ret = queryResponses[0];

  if(ret) {
    const list = JSON.parse(ret);

    if(!list.length) {
      logger.debug('no dns records found on chain');
    } else {
      let h = `# replaced by dns listener at new block ${block.number} on ${block.channel_id}\n`;
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
};
