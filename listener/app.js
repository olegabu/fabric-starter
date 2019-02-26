const logger = require('log4js').getLogger('app');
const FabricStarterClient = require('fabric-starter-rest');
const fabricStarterClient = new FabricStarterClient();

const channel = process.env.CHANNEL || 'common';

async function start() {
    await fabricStarterClient.init();

    try {
        await fabricStarterClient.loginOrRegister('listener');
    } catch(e) {
        logger.error('loginOrRegister', e);
    }

    fabricStarterClient.registerBlockEvent(channel, block => {
        logger.debug(`block ${block.number} on ${block.channel_id}`);
    }, e => {
        logger.error('registerBlockEvent', e);
    });

    logger.info(`registered for block event on ${channel}`);

    const channels = await fabricStarterClient.queryChannels();

    logger.info('channels', channels);
}

function sleep(n) {
    Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, n);
}

function halt() {
    // sleep(600000);

    setInterval(() => {
        logger.trace('interval');
    }, 60000)
}

start().then(() => {
    logger.info('started');
}).catch(e => {
    logger.error('cannot start', e);
});

halt();

