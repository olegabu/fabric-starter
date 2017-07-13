/**
 * @class ChannelsController
 * @classdesc
 * @ngInject
 */
function ChannelsController(ChannelService) {

  var ctl = this;

  ctl.channels = [];
  ctl.chaincodes = [];
  ctl.blockInfo = {};


  ctl.updateChannels = function(){
    return ChannelService.list().then(function(dataList){
      ctl.channels = dataList;
    });
  };

  ctl.updateChaincodes = function(){
    return ChannelService.listChaincodes().then(function(dataList){
      ctl.chaincodes = dataList;
    });
  };

  ctl.updateLastBlock = function(){
    return ChannelService.getLastBlock().then(function(blockInfo){
      ctl.blockInfo = blockInfo;
    });
  };

  ctl.scMove = function(){
    ChannelService.scMove('a', 'b', '10');
  };


  ctl.updateChannels()
    .then(function(){
      return ctl.updateChaincodes();
    }).then(function(){
      return ctl.updateLastBlock();
    })
}

angular.module('nsd.controller.channels', ['nsd.service.channel'])
.controller('ChannelsController', ChannelsController);