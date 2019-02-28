const logger = require('log4js').getLogger('app');
const FabricStarterClient = require('fabric-starter-rest');
const fabricStarterClient = new FabricStarterClient();

const channel = process.env.CHANNEL || 'common';
const username = process.env.USERNAME || 'listener';
const password = process.env.PASSWORD || 'pass';
const worker = require(process.env.WORKER || './debug.js');

async function start() {
    await fabricStarterClient.init();

    await fabricStarterClient.loginOrRegister(username, password);

    const channels = await fabricStarterClient.queryChannels();
    logger.info('channels', channels);

    await fabricStarterClient.registerBlockEvent(channel, block => {
        logger.debug(`block ${block.number} on ${block.channel_id}`);

        worker(block, fabricStarterClient);
    }, e => {
        logger.error('registerBlockEvent', e);
    });

    logger.info(`registered for block event on ${channel}`);
}

function wait() {
    setInterval(() => {
        logger.trace('waiting');
    }, 60000);
}

start().then(() => {
    logger.info('started');
}).catch(e => {
    logger.error('cannot start', e);
});

wait();

