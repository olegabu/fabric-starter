/**
 *
 */
angular.module('nsd.controller', [
  'nsd.controller.main',
  'nsd.controller.login',
  'nsd.controller.info',
  'nsd.controller.query',
]);

angular.module('nsd.service', [
  'nsd.service.api',
  'nsd.service.user',
  'nsd.service.channel'
]);

angular.module('nsd.app',[
   'ui.router',
   'ui.bootstrap',
   'ui.materialize',
   'ui.router.title',

   'LocalStorageModule',
   'jsonFormatter',

   'nsd.config.env',
   'nsd.controller',
   'nsd.service',

   'nsd.directive.form',
   'nsd.directive.certificate'
])
.config(function($stateProvider, $urlRouterProvider) {

  $urlRouterProvider.otherwise('/query');

  /*
   Custom state options are:
      visible:boolean  (default:true) - 'false' is hide element from menu. setting abstract:true also hide it
      guest:boolean    (default:true) - when 'false' - prevents unauthorized access to the item
      name:string (default:<stateId>) - menu name

  */
  $stateProvider
    .state('app', {
      url: '/',
      abstract:true,
      templateUrl: 'app.html',
      resolve: {
        // $title: function() { return 'Home'; }
        _config: function(ConfigLoader){ return ConfigLoader.load(); }
      }
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

    .state('app.query', {
      url: 'query',
      templateUrl: 'pages/query.html',
      controller: 'QueryController',
      controllerAs: 'ctl',
      data:{
        name: 'Query/Invoke',
        guest:false,
        // default:true
      }
    })

    .state('app.info', {
      url: 'info',
      templateUrl: 'pages/info.html',
      controller: 'InfoController',
      controllerAs: 'ctl',
      data:{
        name: 'Info',
        guest:false
      }
    });

})
.run(function(UserService, ApiService, $rootScope, $state, $log){
  // goDefault();


  var loginState = 'app.login';

  // https://github.com/angular-ui/ui-router/wiki#state-change-events
  $rootScope.$on('$stateChangeStart',  function(event, toState, toParams, fromState, fromParams, options){
    console.log('$stateChangeStart', toState, fromState);

    var isGuestAllowed = toState.data && toState.data.guest !== false;
    var isLoginState = toState.name == loginState;


    if ( isLoginState && !isGuestAllowed){
      $log.warn('login state cannot be authorized-only');
    }

    if ( !isGuestAllowed && !isLoginState && !UserService.isAuthorized() ){
      event.preventDefault();
      // transitionTo() promise will be rejected with a 'transition prevented' error

      if(fromState.name == ""){
        // just enter the page
        goLogin();
      }
    }
  });

  /**
   *
   */
  function goLogin(){
    $state.go(loginState);
  }

  /**
   *
   */
  // function goDefault(){
  //   var defaultState = getDefaultState();
  //   if(defaultState){
  //     $state.go(defaultState.name);
  //   } else {
  //     $log.warn('No default state');
  //   }
  // }


  /**
   * @return {State}
   */
  function getDefaultState(){
    var states = $state.get()||[];
    for (var i = states.length - 1; i >= 0; i--) {
      if( states[i].data && states[i].data.default===true){
        return states[i];
      }
    }
    return null;
  }

})


/**
 *
 */
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
        },


        requestError:function(rejection){
          globalErrorHandler(rejection);
          throw rejection;
        },
        responseError:function(rejection){
          globalErrorHandler(rejection);
          throw rejection;
        }
    };


    function globalErrorHandler(e){
      e = e || {};
      e.data = e.data || {};

      var statusMsg = e.status ? 'Error' + (e.status != -1?' '+e.status:'') + ': ' + (e.statusText||(e.status==-1?"Connection refused":null)||"Unknown") : null;
      var reason = e.data.message || e.reason || e.message || statusMsg || e || 'Unknown error';
      Materialize.toast(reason, 4000, 'mytoast red') // 4000 is the duration of the toast
    }

})





/**
 * load config from remote endpoint
 * @ngInject
 */
.service('ConfigLoader', function(ApiService, $rootScope){

    /** @type {Promise<FabricConfig>} */
    var _configPromise;
    var _config = null;

    function _resolveConfig(){
      if( !_configPromise ){
        _configPromise = ApiService.getConfig()
          .then(function(config){
            $rootScope._config = config;
            _config = config;
            _extendConfig();
            return config;
          });
      }
      return _configPromise;
    }


    function _extendConfig(){
      var netConfig = _config.network;
      netConfig.getOrgs = function(){
        var keys = Object.keys(netConfig).filter(function(key){ return key.startsWith('org')});

        keys.forEach(function(key){
          netConfig[key].id = key;
        });

        return keys.map(function(key){ return netConfig[key]; });
      };

      netConfig.getPeers = function(orgId){
        var orgConfig = _config.network[orgId]||{};
        var keys = Object.keys(orgConfig).filter(function(key){ return key.startsWith('peer')});

        keys.forEach(function(key){
          orgConfig[key].id = key;
          orgConfig[key].host = getHost(orgConfig[key].requests);
          orgConfig[key].org = orgId;
        });

        return keys.map(function(key){ return orgConfig[key]; });
      };
    }

    function getHost(address){
      //                             1111       222222
      var m = (address||"").match(/^(\w+:)?\/\/([^\/]+)/) || [];
      return m[2];
    }

    return {
      load:_resolveConfig,
      get:function(){ return _config; }
    };
})

/**
 * @ngInject
 */
.run(function(ConfigLoader){
  ConfigLoader.load();
})


