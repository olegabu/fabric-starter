angular.module('app', ['ui.router',
                       'ui.bootstrap',
                       'ui.materialize',
                       'ui.router.title',
                       'timeService',
                       'userService',
                       'peerService',
                       'demoController',
                       'bondListController',
                       'issuerContractListController',
                       'investorContractListController',
                       'marketController',
                       'offlineController',
                       'config',
                       'MyBlockchain'])

.config(function($stateProvider, $urlRouterProvider) {

  $urlRouterProvider.otherwise('/');

  $stateProvider
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

});
