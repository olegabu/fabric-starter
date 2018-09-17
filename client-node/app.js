const express = require("express");
const bodyParser = require("body-parser");
const app = express();
const logger = require('log4js').getLogger('app');
const jwt = require('express-jwt');
const FabricStarterClient = require('./fabric-starter-client');
const fabricStarterClient = new FabricStarterClient();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const asyncMiddleware = fn =>
  (req, res, next) => {
    Promise.resolve(fn(req, res, next))
      .catch(next);
  };

const appRouter = (app) => {
  app.use(jwt({ secret: fabricStarterClient.getSecret()}).unless({path: ['/', '/users']}));
  app.use(async (req, res, next) => {
    await fabricStarterClient.init();
    if(req.user) {
      const login = req.user.sub;
      logger.info('login', login);
      await fabricStarterClient.loginOrRegister(login);
    }
    next();
  });

  app.get('/', (req, res) => {
    res.status(200).send('Welcome to fabric-starter REST server');
  });

  app.get('/chaincodes', asyncMiddleware(async (req, res) => {
    res.json(await fabricStarterClient.queryInstalledChaincodes());
  }));

  app.post('/chaincodes', asyncMiddleware(async (req, res) => {
    res.status(501).send('installing chaincode on peer not implemented');
  }));

  app.post('/users', asyncMiddleware(async (req, res) => {
    await fabricStarterClient.loginOrRegister(req.body.login, req.body.password);
    res.json(fabricStarterClient.getToken());
  }));

  app.get('/channels', asyncMiddleware(async (req, res) => {
    res.json(await fabricStarterClient.queryChannels());
  }));

  app.post('/channels', asyncMiddleware(async (req, res) => {
    res.status(501).send('adding channel not implemented');
  }));

  app.get('/channels/:channelId', asyncMiddleware(async (req, res) => {
    res.json(await fabricStarterClient.queryInfo(req.params.channelId));
  }));

  app.get('/channels/:channelId/orgs', asyncMiddleware(async (req, res) => {
    res.json(await fabricStarterClient.getOrganizations(req.params.channelId));
  }));

  app.post('/channels/:channelId/orgs', asyncMiddleware(async (req, res) => {
    res.status(501).send('adding organization to channel not implemented');
  }));

  app.get('/channels/:channelId/blocks/:number', asyncMiddleware(async (req, res) => {
    res.json(await fabricStarterClient.queryBlock(req.params.channelId, parseInt(req.params.number)));
  }));

  app.get('/channels/:channelId/transactions/:id', asyncMiddleware(async (req, res) => {
    res.json(await fabricStarterClient.queryTransaction(req.params.channelId, req.params.id));
  }));

  app.get('/channels/:channelId/chaincodes', asyncMiddleware(async (req, res) => {
    res.json(await fabricStarterClient.queryInstantiatedChaincodes(req.params.channelId));
  }));

  app.post('/channels/:channelId/chaincodes', asyncMiddleware(async (req, res) => {
    res.status(501).send('instantiating chaincode on channel not implemented');
  }));

  app.get('/channels/:channelId/chaincodes/:chaincodeId', asyncMiddleware(async (req, res) => {
    res.json(await fabricStarterClient.query(req.params.channelId, req.params.chaincodeId, req.query.fcn, req.query.args, req.query.targets));
  }));

  app.post('/channels/:channelId/chaincodes/:chaincodeId', asyncMiddleware(async (req, res) => {
    res.json(await fabricStarterClient.invoke(req.params.channelId, req.params.chaincodeId, req.body.fcn, req.body.args, req.body.targets));
  }));

};

appRouter(app);

const server = app.listen(process.env.PORT || 3000, function () {
  logger.info('fabric-starter rest server running on port', server.address().port);
});
