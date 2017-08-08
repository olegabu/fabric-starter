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
  'nsd.service.channel',
  'nsd.service.socket'
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
   'nsd.directive.certificate',
   'nsd.directive.blockchain'
])
.config(function($stateProvider) {

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
        default: true,
        name: 'Info',
        guest:false
      }
    });

})

// THIS method should be called BEFORE navigateDefault()
.run(function(UserService, $rootScope, $state, $log){

  //
  var loginState = 'app.login';

  // https://github.com/angular-ui/ui-router/wiki#state-change-events
  $rootScope.$on('$stateChangeStart',  function(event, toState, toParams, fromState, fromParams, options){
    // console.log('$stateChangeStart', event, toState, toParams);

    // check access
    var isAllowed = UserService.canAccess(toState);
    var isLoginState = toState.name == loginState;

    if ( isLoginState && !isAllowed){
      $log.warn('login state cannot be forbidden');
      isAllowed = true;
    }

    // console.log('$stateChangeStart access: authorized - %s, allowed - %s, login - %s', UserService.isAuthorized(), isAllowed, isLoginState);
    // prevent navigation to forbidden pages
    if ( !UserService.isAuthorized() && !isAllowed && !isLoginState){
      event.preventDefault(); // transitionTo() promise will be rejected with a 'transition prevented' error
      if(fromState.name == ""){
        // just enter the page - redirect to login page
        goLogin();
      }
    }
  });

  // set state data to root scope
  $rootScope.$on('$stateChangeSuccess',  function(event, toState, toParams, fromState, fromParams, options){
    $rootScope.$state = toState;
    $rootScope.$stateParams = toParams;
  });

  /**
   *
   */
  function goLogin(){
    $state.go(loginState);
  }
})

// instead of: $urlRouterProvider.otherwise('/default');
.run(function navigateDefault($state, $log, $rootScope){

  var defaultState = getDefaultState();
  if(!defaultState){
    $log.warn('No default state set. Please, mark any state as default by setting "data:{ default:true }"');
  }
  $rootScope.stateDefault = defaultState; // TODO: remove?

  // instead of: $urlRouterProvider.otherwise('/default');
  if($state.current.name == "" && defaultState){
    $state.go(defaultState.name);
  }

  /**
   * @return {State}
   */
  function getDefaultState(){
    var states = $state.get()||[];
    for (var i = states.length - 1; i >= 0; i--) {
      if( states[i].data && states[i].data.default === true){
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

            // $rootScope._tokenInfo is set in UserService
            if($rootScope._tokenInfo){
              config.headers['Authorization'] = 'Bearer '+$rootScope._tokenInfo.token;
            }
            return config;
        },

        // throws error, so '$exceptionHandler' service will caught it
        requestError:function(rejection){
          throw rejection;
        },
        responseError:function(rejection){
          throw rejection;
        }
    };

})



/**
 * @ngInject
 */
.run(function(ConfigLoader){
  ConfigLoader.load();
})


.factory('$exceptionHandler', function ($window) {
    $window.onunhandledrejection = function(e) {
        // console.warn('onunhandledrejection', e);
        e = e || {};
        onError(e);
    };

    function onError(exception){
        // filter network 403 errors
        if (exception.status !== 403 ){
            globalErrorHandler(exception);
        }
    }

    return onError;
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

     /**
     * add getOrgs() to netConfig
     * add getPeers(orgId:string) to netConfig

     * add id to org info

     * add id to peer info
     * add org to peer info
     * add host to peer info
     */
    function _extendConfig(){
      var netConfig = _config['network-config'];

      Object.keys(netConfig)
        .filter(function(key){ return key != 'orderer' })
        .forEach(function(orgId){

          // add org.id
          netConfig[orgId].id = orgId;

          var orgConfig = netConfig[orgId] || {};

          // add peers stuff
          Object.keys(orgConfig)
            .filter(function(key){ return key.startsWith('peer') })
            .forEach(function(peerId){
              orgConfig[peerId].id   = peerId;
              orgConfig[peerId].host = getHost(orgConfig[peerId].requests);
              orgConfig[peerId].org  = orgId;
            });

        });
    }



    function getPeers(orgId){
        var netConfig = _config['network-config'];
        var orgConfig = netConfig[orgId]||{};

        return Object.keys(orgConfig)
          .filter(function(key){ return key.startsWith('peer')})
          .map(function(key){ return orgConfig[key]; });
    }

    function getOrgs(){
      var netConfig = _config['network-config'];

      return Object.keys(netConfig)
        .filter(function(key){ return key != 'orderer'})
        .map(function(key){ return netConfig[key]; });
    }

    /**
     *
     */
    function getHost(address){
      //                             1111       222222
      var m = (address||"").match(/^(\w+:)?\/\/([^\/]+)/) || [];
      return m[2];
    }

    return {
      load:_resolveConfig,
      getOrgs: getOrgs,
      getPeers: getPeers,

      get:function(){ return _config; }
    };
})

/**
 * @ngInject
 */
.run(function(ConfigLoader){
  ConfigLoader.load();
})






/**
 *
 */
function globalErrorHandler(e){
  console.warn('globalErrorHandler', e);
  e = e || {};
  if(typeof e == "string"){
    e = {message:e};
  }
  e.data = e.data || {};

  var statusMsg = e.status ? 'Error' + (e.status != -1?' '+e.status:'') + ': ' + (e.statusText||(e.status==-1?"Connection refused":null)||"Unknown") : null;
  var reason = e.data.message || e.reason || e.message || statusMsg || e || 'Unknown error';
  Materialize.toast(reason, 4000, 'mytoast red') // 4000 is the duration of the toast
}
