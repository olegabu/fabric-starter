/**
 * @class InfoController
 * @classdesc
 * @ngInject
 */
function InfoController(ChannelService) {

  var ctl = this;

  ctl.channels = [];
  ctl.chaincodes = [];
  ctl.blockInfo = {};
  ctl.transaction = {};


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



  ctl.scMove = function(){
    ChannelService.scMove('a', 'b', '10');
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