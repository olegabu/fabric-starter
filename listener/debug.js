const logger = require('log4js').getLogger('debug');

module.exports = function(block) {
    logger.debug(JSON.stringify(block));
};

