const logger = require('log4js').getLogger('dns');
const fs = require('fs');

const hostsFile = '/etc/hosts';

module.exports = async function(block, fabricStarterClient) {
    logger.debug(block);

    const queryResponses = await fabricStarterClient.query(block.channel_id, 'dns', 'range', '[]', {});
    logger.trace('queryResponses', queryResponses);

    const ret = queryResponses[0];

    if(ret) {
        const list = JSON.parse(ret);

        let h = '\n';
        list.forEach(o => {
           h = h.concat(o.value, ' ', o.key, '\n');
        });

        fs.appendFile(hostsFile, h, err => {
            if(err) {
                logger.error(`cannot append to ${hostsFile}`, err);
            }
            else {
                logger.info(`appended to ${hostsFile}`, h);
            }
        })
    }
};
