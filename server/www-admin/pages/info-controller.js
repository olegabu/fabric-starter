/**
 * @class InfoController
 * @classdesc
 * @ngInject
 */
function InfoController(ChannelService, ConfigLoader) {

  var ctl = this;

  var channelID = 'mychannel';

  ctl.channels = [];
  ctl.chaincodes = [];
  ctl.blockInfo = null;// {};
  ctl.transaction = {};
  ctl.result = {};

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
    return ChannelService.getTransactionById(channelID, txId).then(function(transaction){
      ctl.transaction = transaction;

      try{
        ctl.result = {};
        // TODO: loop trough actions
        var ns_rwset = ctl.transaction.transactionEnvelope.payload.data.actions[0].payload.action.proposal_response_payload.extension.results.ns_rwset;
        ns_rwset = ns_rwset.filter(function(action){return action.namespace != "lscc"}); // filter system chaincode
        ns_rwset.forEach(function(action){
          ctl.result[action.namespace] = action.rwset.writes.reduce(function(result, element){
            result[element.key] = element.is_delete ? null : element.value;
            return result;
          }, {});

        });
      }catch(e){
        console.info(e);
        ctl.result = {};        
      }
    });
  };


  ctl.getChannels()
    .then(function(){
      return ctl.getChaincodes();
    }).then(function(){
      // TODO: choose channel
      var channelId = ctl.channels[0] ? ctl.channels[0].channel_id : null; // 'mychannel';
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