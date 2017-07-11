/**
 * @class ChannelsController
 * @classdesc
 * @ngInject
 */
function ChannelsController(ChannelService) {

  var ctl = this;

  ctl.channels = [];

  ChannelService.list().then(function(dataList){
    ctl.channels = dataList;
  });

}

angular.module('nsd.controller.channels', ['nsd.service.channel'])
.controller('ChannelsController', ChannelsController);