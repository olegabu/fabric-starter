/**
 * @class InfoController
 * @classdesc
 * @ngInject
 */
function InfoController(ChannelService, ConfigLoader, $scope) {

  var ctl = this;

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
    ctl.chaincodes = null;
    return ChannelService.listChaincodes().then(function(dataList){
      ctl.chaincodes = dataList;
    });
  };

  ctl.getLastBlock = function(channelId){
    ctl.blockInfo = null;
    if(!channelId) return null;
    return ChannelService.getLastBlock(channelId).then(function(blockInfo){
      ctl.blockInfo = blockInfo;
    });
  };


  ctl.getTransaction = function(channelID){

    ctl.transaction = null;
    ctl.result = null;

    if(!ctl.blockInfo) return null;
    var txId = ctl.blockInfo.data.data[0].payload.header.channel_header.tx_id;
    return ChannelService.getTransactionById(channelID, txId).then(function(transaction){
      ctl.transaction = transaction;
      ctl.result = getTxResult(transaction);
    });
  };


  function getTxResult(transaction){
    var result = null;
    try{
      result = {};
      // TODO: loop trough actions
      var ns_rwset = transaction.transactionEnvelope.payload.data.actions[0].payload.action.proposal_response_payload.extension.results.ns_rwset;
      ns_rwset = ns_rwset.filter(function(action){return action.namespace != "lscc"}); // filter system chaincode
      ns_rwset.forEach(function(action){
        result[action.namespace] = action.rwset.writes.reduce(function(result, element){
          result[element.key] = element.is_delete ? null : element.value;
          return result;
        }, {});

      });
    }catch(e){
      console.info(e);
      result = null
    }
    return result;
  }


  $scope.$watch('selectedChannel', function(selectedChannel){
    var channelId = selectedChannel ? selectedChannel.channel_id : null;
    return ctl.getChaincodes(/* TODO: selectedChannel */)
      .then(function(){
        return ctl.getLastBlock(channelId)
      })
      .then(function(){
        return ctl.getTransaction(channelId);
      });
  })

  ctl.getChannels();
}

angular.module('nsd.controller.info', ['nsd.service.channel'])
.controller('InfoController', InfoController);