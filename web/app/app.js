/**
 *
 */
angular.module('nsd.controller', [
  'nsd.controller.main',
  'nsd.controller.login',
  'nsd.controller.channels',
  'nsd.controller.audit',
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

   'LocalStorageModule',
   'jsonFormatter',

   'nsd.config',
   'nsd.controller',
   'nsd.service'
])
.config(function($stateProvider, $urlRouterProvider) {

  $urlRouterProvider.otherwise('/login');

  $stateProvider
    .state('app', {
      url: '/',
      abstract:true,
      templateUrl: 'app.html',
    })
    .state('app.login', {
      url: 'login',
      templateUrl: 'pages/login.html',
      controller: 'LoginController',
      controllerAs: 'ctl',
      data:{
        visible: false
      }
    })
    .state('app.channels', {
      url: 'channels',
      templateUrl: 'pages/channels.html',
      controller: 'ChannelsController',
      controllerAs: 'ctl',
      data:{
        name: 'Channels'
      }
    })
    .state('app.audit', {
      url: 'audit',
      templateUrl: 'pages/audit.html',
      controller: 'AuditController',
      controllerAs: 'ctl',
      data:{
        name: 'Audit'
      }
  //  resolve: {
  //     $title: function() { return 'Home'; }
  //   }
    })

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
