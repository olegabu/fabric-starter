/**
 * @class ChannelService
 * @classdesc
 * @ngInject
 */
function ChannelService(cfg, ApiService) {

  // jshint shadow: true
  var ChannelService = this;

  /**
   * @param {string} user
   */
  ChannelService.list = function(user) {
    return ApiService.channels.list();
  };


}

angular.module('nsd.service.channel', ['nsd.service.api'])
  .service('ChannelService', ChannelService);