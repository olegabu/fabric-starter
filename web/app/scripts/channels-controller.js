/**
 * @class ChannelsController
 * @classdesc
 * @ngInject
 */
function ChannelsController(ChannelService) {

  var ctl = this;

  ctl.channels = [];
  ctl.chaincodes = [];


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


  ctl.updateChannels()
    .then(function(){
      ctl.updateChaincodes();
    });
}

angular.module('nsd.controller.channels', ['nsd.service.channel'])
.controller('ChannelsController', ChannelsController);