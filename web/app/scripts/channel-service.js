/**
 * @class ChannelService
 * @classdesc
 * @ngInject
 */
function ChannelService(cfg, ApiService) {

  // jshint shadow: true
  var ChannelService = this;

  /**
   */
  ChannelService.list = function(user) {
    return ApiService.channels.list();
  };


  /**
   * @param {string} user
   */
  ChannelService.listChaincodes = function(user) {
    return ApiService.chaincodes.list();
  };




}

angular.module('nsd.service.channel', ['nsd.service.api'])
  .service('ChannelService', ChannelService);