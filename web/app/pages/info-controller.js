/**
 * @class InfoController
 * @classdesc
 * @ngInject
 */
function InfoController(ChannelService, ConfigLoader) {

  var ctl = this;

  ctl.channels = [];
  ctl.chaincodes = [];
  ctl.blockInfo = {};
  ctl.transaction = {};

  ctl.networkConfig = (ConfigLoader.get()||{}).network;

  ctl.getOrgs = function(){
    var keys = Object.keys(ctl.networkConfig).filter(function(key){ return key.startsWith('org')});

    return keys.reduce(function(res, key){
      res[key] = ctl.networkConfig[key];
      return res;
    }, {});
  };

  ctl.getPeers = function(orgId){
    var keys = Object.keys(ctl.networkConfig[orgId]).filter(function(key){ return key.startsWith('peer')});

    return keys.reduce(function(res, key){
      res[key] = ctl.networkConfig[orgId][key];
      return res;
    }, {});
  };


  ctl.getChannels = function(){
    return ChannelService.list().then(function(dataList){
      ctl.channels = dataList;
    });
  };

  ctl.getChaincodes = function(){
    return ChannelService.listChaincodes().then(function(dataList){
      ctl.chaincodes = dataList;
    });
  };

  ctl.getLastBlock = function(){
    return ChannelService.getLastBlock().then(function(blockInfo){
      ctl.blockInfo = blockInfo;
    });
  };


  ctl.getTransaction = function(){
    var txId = ctl.blockInfo.data.data[0].payload.header.channel_header.tx_id;
    return ChannelService.getTransactionById(txId).then(function(transaction){
      ctl.transaction = transaction;
    });
  };


  ctl.getChannels()
    .then(function(){
      return ctl.getChaincodes();
    }).then(function(){
      return ctl.getLastBlock();
    }).then(function(){
      return ctl.getTransaction();
    });
}

angular.module('nsd.controller.info', ['nsd.service.channel'])
.controller('InfoController', InfoController);