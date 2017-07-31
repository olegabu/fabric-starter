/**
 * @class InfoController
 * @classdesc
 * @ngInject
 */
function InfoController(ChannelService, ConfigLoader) {

  var ctl = this;

  ctl.channels = [];
  ctl.chaincodes = [];
  ctl.blockInfo = null;// {};
  ctl.transaction = {};

  ctl.networkConfig = (ConfigLoader.get()||{}).network;

  ctl.getOrgs = function(){
    return ctl.networkConfig.getOrgs();
  };

  ctl.getPeers = function(orgId){
    return ctl.networkConfig.getPeers(orgId);
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

  ctl.getLastBlock = function(channelId){
    return ChannelService.getLastBlock(channelId).then(function(blockInfo){
      ctl.blockInfo = blockInfo;
    });
  };


  ctl.getTransaction = function(){
    if(!ctl.blockInfo) return null;
    var txId = ctl.blockInfo.data.data[0].payload.header.channel_header.tx_id;
    return ChannelService.getTransactionById(txId).then(function(transaction){
      ctl.transaction = transaction;
    });
  };


  ctl.getChannels()
    .then(function(){
      return ctl.getChaincodes();
    }).then(function(){
      // TODO: choose channel
      var channelId = ctl.channels[0] ? ctl.channels[0].name : null; // 'mychannel';
      if(!channelId){
        return false;
      }
      return ctl.getLastBlock(channelId);
    }).then(function(){
      return ctl.getTransaction();
    });
}

angular.module('nsd.controller.info', ['nsd.service.channel'])
.controller('InfoController', InfoController);