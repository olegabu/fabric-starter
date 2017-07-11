/**
 *
 */
angular.module('nsd.controller', [
  'nsd.controller.login',
  'nsd.controller.channels',
]);

angular.module('nsd.service', [
  'nsd.service.api',
  'nsd.service.user',
  'nsd.service.channel'
]);

angular.module('nsd.app',
  ['ui.router',
   'ui.bootstrap',
   'ui.materialize',
   'ui.router.title',
   'timeService',
   // 'userService',
   'peerService',
   'demoController',
   'bondListController',
   'issuerContractListController',
   'investorContractListController',
   'marketController',
   'offlineController',
   'config',
   'MyBlockchain',

   'LocalStorageModule',

   'nsd.controller',
   'nsd.service'
])
.config(function($stateProvider, $urlRouterProvider) {

  $urlRouterProvider.otherwise('/');

  $stateProvider
  .state('app', {
    url: '/',
    templateUrl: 'partials/app.html',
  })
  .state('app.login', {
    url: 'login',
    templateUrl: 'partials/login.html',
    controller: 'LoginController',
    controllerAs: 'ctl'
  })
  .state('app.channels', {
    url: 'channels',
    templateUrl: 'partials/channels.html',
    controller: 'ChannelsController',
    controllerAs: 'ctl'
  })



  .state('demo', {
    url: '/',
    templateUrl: 'partials/demo.html',
    controller: 'DemoController as ctl',
    resolve: {
      $title: function() { return 'Home'; }
    }
  })
  .state('demo.issuerContractList', {
    url: 'issuer-contracts',
    templateUrl: 'partials/issuer-contract-list.html',
    controller: 'IssuerContractListController as ctl',
    resolve: {
      $title: function(UserService) { return 'Contracts of'; }
    }
  })
  .state('demo.investorContractList', {
    url: 'investor-contracts',
    templateUrl: 'partials/investor-contract-list.html',
    controller: 'InvestorContractListController as ctl',
    resolve: {
      $title: function(UserService) { return 'Contracts of'; }
    }
  })
  .state('demo.bondList', {
    url: 'bonds',
    templateUrl: 'partials/bond-list.html',
    controller: 'BondListController as ctl',
    resolve: {
      $title: function(UserService) { return 'Bonds of'; }
    }
  })
  .state('demo.market', {
    url: 'market',
    templateUrl: 'partials/market.html',
    controller: 'MarketController as ctl',
    resolve: {
      $title: function(UserService) { return 'Market for'; }
    }
  })
  .state('demo.offline', {
    url: 'offline',
    templateUrl: 'partials/offline.html',
    controller: 'OfflineController as ctl',
    resolve: {
      $title: function() { return 'Offline'; }
    }
  });

})
.run(function(UserService){
  UserService.restoreAuthorization();
})

.config(function($httpProvider) {
  $httpProvider.interceptors.push('bearerAuthIntercepter');
})

/**
 * inject 'X-Requested-With' header
 * inject 'Authorization: Bearer' token
 */
.factory('bearerAuthIntercepter', function($rootScope){
    return {
        request: function(config) {
            config.headers['X-Requested-With'] = 'XMLHttpRequest'; // make ajax request visible among the others
            config.withCredentials = true;

            if($rootScope._tokenInfo){
              config.headers['Authorization'] = 'Bearer '+$rootScope._tokenInfo.token;
            }
            return config;
        }
    };

});
