const log4js = require('log4js');
log4js.configure({appenders: {stdout: { type: 'stdout' }},categories: {default: { appenders: ['stdout'], level: 'ALL'}}});
const logger = log4js.getLogger('FabricStarterClient');
const Client = require('fabric-client');

//const networkConfigFile = '../crypto-config/network.json'; // or .yaml
//const networkConfig = require('../crypto-config/network.json');

const invokeTimeout = process.env.INVOKE_TIMEOUT || 60000;
const asLocalhost = (process.env.DISCOVER_AS_LOCALHOST === 'true');

logger.debug(`invokeTimeout=${invokeTimeout} asLocalhost=${asLocalhost} type ${typeof asLocalhost} process.env.DISCOVER_AS_LOCALHOST=${process.env.DISCOVER_AS_LOCALHOST}`);

class FabricStarterClient {
  constructor(networkConfig) {
    this.networkConfig = networkConfig || require('./network')();
    logger.info('constructing with network config', JSON.stringify(this.networkConfig));
    this.client = Client.loadFromConfig(this.networkConfig); // or networkConfigFile
    this.peer = this.client.getPeersForOrg()[0];
    this.org = this.networkConfig.client.organization;
    this.affiliation = this.org;
  }

  async init() {
    await this.client.initCredentialStores();
    this.fabricCaClient = this.client.getCertificateAuthority();
  }

  async login(username, password) {
    this.user = await this.client.setUserContext({username: username, password: password});
  }

  async register(username, password, affiliation) {
    const registrar = this.fabricCaClient.getRegistrar()[0];
    const admin = await this.client.setUserContext({username: registrar.enrollId, password: registrar.enrollSecret});
    await this.fabricCaClient.register({
      enrollmentID: username,
      enrollmentSecret: password,
      affiliation: affiliation || this.affiliation,
      maxEnrollments: -1
    }, admin);
  }

  async loginOrRegister(username, password, affiliation) {
    try {
      await this.login(username, password);
    } catch (e) {
      await this.register(username, password, affiliation);
      await this.login(username, password);
    }
  }

  getSecret() {
    const signingIdentity = this.client._getSigningIdentity(true);
    const signedBytes = signingIdentity.sign(this.org);
    return String.fromCharCode.apply(null, signedBytes);
  }

  async queryChannels() {
    const channelQueryResponse = await this.client.queryChannels(this.peer, true);
    return channelQueryResponse.getChannels();
  }

  async queryInstalledChaincodes() {
    const chaincodeQueryResponse = await this.client.queryInstalledChaincodes(this.peer, true);
    return chaincodeQueryResponse.getChaincodes();
  }

  async getChannel(channelId) {
    let channel;
    try {
      channel = this.client.getChannel(channelId);
    } catch (e) {
      channel = this.client.newChannel(channelId);
      channel.addPeer(this.peer);
    }
    await channel.initialize({discover: true, asLocalhost: asLocalhost});
    // logger.trace('channel', channel);
    return channel;
  }

  getChannelEventHub(channel) {
    //const channelEventHub = channel.getChannelEventHub(this.peer.getName());
    const channelEventHub = channel.newChannelEventHub(this.peer.getName());
    // const channelEventHub = channel.getChannelEventHubsForOrg()[0];
    channelEventHub.connect();
    return channelEventHub;
  }

  async invoke(channelId, chaincodeId, fcn, args, targets) {
    const channel = await this.getChannel(channelId);

    const tx_id = this.client.newTransactionID(/*true*/);
    const proposal = {
      chaincodeId: chaincodeId,
      fcn: fcn,
      args: args,
      txId: tx_id,
      targets: targets || [this.peer]
    };

    const proposalResponse = await channel.sendTransactionProposal(proposal);

    // logger.trace('proposalResponse', proposalResponse);

    const transactionRequest = {
      proposalResponses: proposalResponse[0],
      proposal: proposalResponse[1],
    };

    const promise = this.waitForTransactionEvent(tx_id, channel);

    const broadcastResponse = await channel.sendTransaction(transactionRequest);
    logger.trace('broadcastResponse', broadcastResponse);

    return promise;
  }

  async waitForTransactionEvent(tx_id, channel) {
    const timeout = invokeTimeout;
    const id = tx_id.getTransactionID();
    let timeoutHandle;

    const timeoutPromise = new Promise((resolve, reject) => {
      timeoutHandle = setTimeout(() => {
        const msg = `timed out waiting for transaction ${id} after ${timeout}`;
        logger.error(msg);
        reject(new Error(msg));
      }, timeout);
    });

    const channelEventHub = this.getChannelEventHub(channel);

    const eventPromise = new Promise((resolve, reject) => {
      logger.trace(`registerTxEvent ${id}`);

      channelEventHub.registerTxEvent(id, (txid, status, blockNumber) => {
        logger.debug(`committed transaction ${txid} as ${status} in block ${blockNumber}`);
        resolve({txid: txid, status: status, blockNumber: blockNumber});
      }, (e) => {
        logger.error(`registerTxEvent ${e}`);
        reject(new Error(e));
      });
    });

    const racePromise = Promise.race([eventPromise, timeoutPromise]);

    racePromise.catch(() => {
      clearTimeout(timeoutHandle);
      channelEventHub.disconnect();
    }).then(() => {
      clearTimeout(timeoutHandle);
      channelEventHub.disconnect();
    });

    return racePromise;
  }

  async query(channelId, chaincodeId, fcn, args, targets) {
    const channel = await this.getChannel(channelId);

    const request = {
      chaincodeId: chaincodeId,
      fcn: fcn,
      args: args,
      targets: targets || [this.peer]
    };

    logger.trace('query', request);

    const responses = await channel.queryByChaincode(request);

    return responses.map(r => {
      return r.toString('utf8');
    });
  }

  async getOrganizations(channelId) {
    const channel = await this.getChannel(channelId);
    return channel.getOrganizations();
  }

  async queryInstantiatedChaincodes(channelId) {
    const channel = await this.getChannel(channelId);
    return await channel.queryInstantiatedChaincodes();
  }

  async queryInfo(channelId) {
    const channel = await this.getChannel(channelId);
    return await channel.queryInfo(this.peer, true);
  }

  async queryBlock(channelId, number) {
    const channel = await this.getChannel(channelId);
    return await channel.queryBlock(number, this.peer, /*, true*/);
  }

  async queryTransaction(channelId, id) {
    const channel = await this.getChannel(channelId);
    return await channel.queryTransaction(id, this.peer, /*, true*/);
  }

  getPeersForOrg(mspid) {
    return this.client.getPeersForOrg(mspid);
  }

  getMspid() {
    return this.client.getMspid();
  }

  getNetworkConfig() {
    return this.networkConfig;
  }

  getPeersForOrgOnChannel(channelId) {
    return this.client.getPeersForOrgOnChannel(channelId);
  }

  async registerBlockEvent(channelId, onEvent, onError) {
    const channel = await this.getChannel(channelId);
    const channelEventHub = this.getChannelEventHub(channel);
    return channelEventHub.registerBlockEvent(onEvent, onError);
  }

  async disconnectChannelEventHub(channelId) {
    const channel = await this.getChannel(channelId);
    const channelEventHub = this.getChannelEventHub(channel);
    return channelEventHub.disconnect();
  }
}

module.exports = FabricStarterClient;
