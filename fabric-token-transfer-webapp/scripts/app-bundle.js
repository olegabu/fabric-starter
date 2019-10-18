define('text!styles/spinners.css', ['module'], function(module) { module.exports = ".spinner-blocker-screen {\n  z-index: 9990;\n  height: 100%;\n  width: 100%;\n  background: #000000;\n  opacity: 0.2;\n  left: 0;\n  top: 0;\n  position: fixed;\n}\n.spinner-screen {\n  z-index: 9991;\n  /*margin: 100px auto;*/\n  position: fixed;\n  left: 50%;\n  top: 200px;\n\n  margin: auto auto;\n  width: 40px;\n  height: 40px;\n  background-color: #AA0000;\n\n  -webkit-animation: sk-rotateplane 1.2s infinite ease-in-out;\n  animation: sk-rotateplane 1.2s infinite ease-in-out;\n}\n\n\n.spinner-blocker-context {\n  /*cursor: not-allowed;*/\n  background: rgba(0, 0, 0, 0.2);\n  /*pointer-events: none;*/\n  /*content: \" \";*/\n  z-index: 9990;\n  display: block;\n  position: absolute;\n  top: 0;\n  left: 0;\n  width: 100%;\n  height: 100%;\n  color: white;\n\n  animation: sk-colorfade 10s;\n  -webkit-animation: sk-colorfade 10s;\n}\n\n.spinner-context {\n  z-index: 9991;\n  position: absolute;\n  left: calc(50% - 20px);\n  top: calc(50% - 20px);\n\n  margin: auto auto;\n  width: 40px;\n  height: 40px;\n  background-color: #d9edf7;\n\n  -webkit-animation: sk-rotateplane 1.2s infinite ease-in-out;\n  animation: sk-rotateplane 1.2s infinite ease-in-out;\n}\n\n\n@keyframes sk-colorfade\n{\n  0%   {background: rgba(0, 0, 0, 0);}\n  100% {background: rgba(0, 0, 0, 0.2);}\n}\n\n@-webkit-keyframes sk-colorfade\n{\n  0%   {background: rgba(0, 0, 0, 0);}\n  100% {background: rgba(0, 0, 0, 0.2);}\n}\n\n\n@-webkit-keyframes sk-rotateplane {\n  0% { -webkit-transform: perspective(120px) }\n  50% { -webkit-transform: perspective(120px) rotateY(180deg) }\n  100% { -webkit-transform: perspective(120px) rotateY(180deg)  rotateX(180deg) }\n}\n\n@keyframes sk-rotateplane {\n  0% {\n    transform: perspective(120px) rotateX(0deg) rotateY(0deg);\n    -webkit-transform: perspective(120px) rotateX(0deg) rotateY(0deg)\n  } 50% {\n      transform: perspective(120px) rotateX(-180.1deg) rotateY(0deg);\n      -webkit-transform: perspective(120px) rotateX(-180.1deg) rotateY(0deg)\n    } 100% {\n        transform: perspective(120px) rotateX(-180deg) rotateY(-179.9deg);\n        -webkit-transform: perspective(120px) rotateX(-180deg) rotateY(-179.9deg);\n      }\n}\n\n\n\n.progress-line, .progress-line:before {\n  height: 3px;\n  width: 100%;\n  margin: 0;\n}\n.progress-line {\n  background-color: #b3d4fc;\n  display: -webkit-flex;\n  display: flex;\n}\n.progress-line:before {\n  background-color: #3f51b5;\n  content: '';\n  -webkit-animation: running-progress 2s cubic-bezier(0.4, 0, 0.2, 1) infinite;\n  animation: running-progress 2s cubic-bezier(0.4, 0, 0.2, 1) infinite;\n}\n@-webkit-keyframes running-progress {\n  0% { margin-left: 0px; margin-right: 100%; }\n  50% { margin-left: 25%; margin-right: 0%; }\n  100% { margin-left: 100%; margin-right: 0; }\n}\n@keyframes running-progress {\n  0% { margin-left: 0px; margin-right: 100%; }\n  50% { margin-left: 25%; margin-right: 0%; }\n  100% { margin-left: 100%; margin-right: 0; }\n}\n"; });
define('text!styles/app.css', ['module'], function(module) { module.exports = "div.tooltip {\n  position: absolute;\n  width: auto;\n  padding: 10px;\n  background-color: #ffffff;\n  top: 0px;\n  visibility: hidden;\n  transition: all 0.15s ease;\n  color: #333;\n  border-radius: 5px;\n  border-style: outset;\n  box-shadow: 2px 2px 1px silver;\n  margin-top: -50px;\n  margin-left: 20px;\n}\n\ninput:hover + div.tooltip {\n  opacity: 1.0;\n  visibility: visible;\n  transition: all 0.15s ease;\n  color: #000;\n  border-radius: 4px;\n  box-shadow: 2px 2px 1px silver;\n}\n\n/*table section*/\n.aut-sort:before{\n  font-family: FontAwesome;\n  padding-right: 0.5em;\n  width: 1.28571429em;\n  display: inline-block;\n  text-align: center;\n}\n\n.aut-sortable:before{\n  content: \"\\f0dc\";\n}\n\n.aut-asc:before{\n  content: \"\\f160\";\n}\n\n.aut-desc:before{\n  content: \"\\f161\";\n}\n\n.table td, .table th {\n  padding: .25rem;\n  vertical-align: unset;\n}\n\n.multi-tab-form .tab-pane {\n  margin-top: 5px;\n}\n\n.aut-row-handy-sel{\n  background-color : #d9edf7 !important;\n}\n\n.widget-selected {\n  background-color : #d9edf7 !important;\n}\n\n.aut-table-container{\n  position: relative;\n\n}\n\n.aut-table-head {\n  white-space: nowrap !important;\n}\n\n.aut-table-body{\n\n}\n\n.aut-pager-container{\n  /*position: absolute;*/\n  width: 100%;\n  margin-bottom: 5px;\n  display: flex;\n}\n\n.aut-pager-pages > ul{\n  margin-bottom: 0px;\n}\n\n.aut-table-card{\n  /*margin-top: 0.5rem;*/\n  /*margin-bottom: 1.3rem;*/\n\n  display: flex;\n  flex-direction: column;\n\n  /*margin-top: 0.5rem;*/\n  /*margin-bottom: -1rem;*/\n  /*padding-bottom: 1rem;*/\n\n  /*padding: 0px 0px 0px 0px;*/\n}\n\n.aut-splitter-card{\n  margin-top: 0.1rem;\n  margin-bottom: 0.1rem;\n}\n\n.aut-splitter-card > div.card-body {\n  padding: 0.2rem;\n}\n\n.aut-table-card-title{\n  position: absolute;\n  top: 1px;\n  left: 3px;\n}\n\n.aut-form-card-container{\n  /*display: flex;*/\n}\n\n.aut-form-card{\n  /*padding: 0;*/\n}\n\n.aut-form-card-close {\n  margin-left: 15px;\n  margin-top: 15px;\n  margin-right: auto;\n  float: left;\n  display: flex;\n  cursor: pointer;\n  color: #5cb85c;\n}\n\n.aut-tooltip-container{\n  position: relative;\n  display: inline-block;\n  /*border-bottom: 1px dotted black; */\n}\n\n.aut-tooltip-container .aut-tooltip {\n  visibility: hidden;\n  width: 120px;\n  background-color: black;\n  color: #fff;\n  text-align: center;\n  padding: 5px 0;\n  border-radius: 6px;\n\n  /* Position the tooltip text - see examples below! */\n  position: absolute;\n  z-index: 1;\n  top: -5px;\n  right: 125%;\n}\n\n.aut-tooltip-container .aut-tooltip::after {\n  content: \" \";\n  position: absolute;\n  top: 50%;\n  left: 100%; /* To the right of the tooltip */\n  margin-top: -5px;\n  border-width: 5px;\n  border-style: solid;\n  border-color: transparent transparent transparent black;\n}\n\n.aut-tooltip-container:hover .aut-tooltip {\n  visibility: visible;\n  opacity: 1;\n}\n\n\n.aut-row-body-headed > tr{\n\n}\n\n.aut-table-headed tbody:nth-child(odd){\n  background-color: rgba(222, 226, 230,.05);\n}\n\n.aut-table-headed tbody:nth-child(even){\n  background-color: rgba(0,0,0,.05);\n}\n\n.aut-row-body-headed  th{\n  font-size: small;\n}\n\n.aut-row-body-headed  th[colspan]{\n  text-align: center;\n}\n\n\n.aut-row-body-headed td[rowspan] {\n  vertical-align:middle;\n}\n\n.aut-unicode-glyph {\n  font-family: FontAwesome;\n  padding-right: 0.5em;\n  width: 1.28571429em;\n  display: inline-block;\n  text-align: center;\n}\n\n.aut-valid:before {\n  content: \"\\f14a\";\n}\n\n.aut-notvalid:before {\n  content: \"\\f071\";\n}\n\nth[data-filtered=\"filtered\"]:after {\n  font-family: FontAwesome;\n  padding-right: 0.5em;\n  width: 1.28571429em;\n  display: inline-block;\n  text-align: center;\n  margin-left: 10px;\n  content: \"\\f0b0\";\n}\n\n\n.widget-row-40p {\n  /*display: table-row;*/\n  overflow-y: auto;\n  /*overflow-x: hidden ;*/\n  height:40vh;\n}\n\n.widget-row-60p {\n  /*display: table-row;*/\n  overflow-y: scroll;\n  overflow-x: hidden ;\n\n  height:60vh;\n}\n\n.widget-row-full {\n  /*display: flex;*/\n  flex: 1;\n  overflow-y: auto;\n  /*min-height: 100%;*/\n\n  /*overflow-x: hidden ;*/\n  /*height:calc(100vh - 184px);*/\n}\n\n.flex-fill-column {\n  flex: 1;\n  display: flex;\n  flex-direction: column;\n  position: relative;\n  overflow-y: auto;\n}\n\n.scrolled-menu {\n  height: auto;\n  max-height: 40vh;\n  overflow-y: auto;\n  overflow-x: hidden;\n}\n\n.dropdown-menu > li > .dropdown-menu-item {\n  clear: both;\n  color: #333;\n  display: block;\n  padding: 3px 20px;\n  white-space: nowrap;\n  margin: 5px 0;\n  width: 100%;\n  text-align: left;\n  text-decoration: none;\n  outline: none;\n  cursor: pointer;\n  -moz-user-select: none;\n  user-select: none;\n}\n/*.dropdown-menu > li:hover .dropdown-menu-item,*/\n/*.dropdown-menu > li:focus .dropdown-menu-item{*/\n  /*background-color: #f5f5f5;*/\n  /*color: #262625;*/\n/*}*/\n.dropdown-menu > li > .dropdown-menu-item.checkbox {\n  margin: 0 0 0 10px;\n  font-weight: normal;\n}\n\n.dropdown-menu > li > .dropdown-menu-item.checkbox input {\n  display: none;\n}\n\n.page-footer {\n  /*position: absolute;*/\n  /*bottom: 0;*/\n  width: 100%;\n\n  height: 2.5rem;\n  line-height: 2.5rem;\n  background-color: #f5f5f5;\n\n  position: relative;\n  display: flex;\n\n  flex-direction: column;\n  max-height: 100%;\n  z-index: 100;\n\n  flex: none;\n}\n\n\nbody > .container {\n  padding: 2.5rem 15px 0;\n}\n\nhtml, body {\n  height: 100%;\n  margin: 0;\n  /*min-height: 100%;*/\n}\n\nbody {\n  display: flex;\n  flex-direction: column;\n}\n\n.page-footer > .container {\n  padding-right: 15px;\n  padding-left: 15px;\n}\n\n.page-footer.opened{\n  height: 150px;\n}\n\n.page-footer.closed{\n  height: 2.5rem;\n}\n\n.page-wrapper {\n  display: flex;\n  flex-direction: column;\n  height: 100%;\n  /*width: 100vw;*/\n  width: 100%;\n}\n\n\n.tools-body-wrapper {\n  height: calc(100% - 2.5rem);\n  width: 100%;\n  display: flex;\n  flex-direction: column;\n  position: relative;\n}\n\n/*display: flex;*/\n/*position: relative;*/\n/*background-color: rgb(28, 32, 34);*/\n/*height: calc(100% - 2.5rem);*/\n\n/*.page-header, .page-footer {*/\n  /*background: silver;*/\n/*}*/\n\n.page-content {\n  flex: 1;\n  overflow: auto;\n  position: relative;\n  /*flex: 1 1 0%;*/\n}\n\n\n.alert-status:before{\n  font-family: FontAwesome;\n  font-size: 1em;\n  padding-right: 0.5em;\n  width: 1em;\n  display: inline-block;\n  text-align: center;\n  color: rgba(128, 128, 128, 0.5);\n}\n\n.alert-transit {\n  -webkit-animation: running-alert 5s forwards;\n  animation: running-alert 5s forwards;\n}\n\n.alert-transit:before {\n  -webkit-animation: running-alert 5s forwards;\n  animation: running-alert 5s forwards;\n}\n\n\n.alert-passiv {\n  /*color: rgba(128, 128, 128, 0.5) !important;*/\n}\n\n.alert-passiv:before {\n  /*color: rgba(128, 128, 128, 0.5) !important;*/\n}\n\n@-webkit-keyframes running-alert {\n  0% { background-color: lightgrey}\n  100% { background-color: rgba(128, 128, 128, 0.0);}\n}\n@keyframes running-alert {\n  0% { background-color: lightgrey}\n  100% { background-color: rgba(128, 128, 128, 0.0);}\n}\n\n/*fading of alert switched off*/\n/*.alert-passiv {*/\n/*color: rgba(128, 128, 128, 0.5) !important;*/\n/*}*/\n\n/*.alert-passiv:before {*/\n/*color: rgba(128, 128, 128, 0.5) !important;*/\n/*}*/\n\n\n/*@-webkit-keyframes running-alert {*/\n/*0% { }*/\n/*100% { color: rgba(128, 128, 128, 0.5);}*/\n/*}*/\n/*@keyframes running-alert {*/\n/*0% { }*/\n/*100% { color: rgba(128, 128, 128, 0.5);}*/\n/*}*/\n/*fading switched off*/\n\n\n.alert-status-danger:before{\n  content: \"\\f071\";\n  color: #dc3545;\n}\n\n.alert-status-danger {\n  color: #dc3545;\n}\n\n\n.alert-status-success:before{\n  content: \"\\f058\";\n  color: #28a745;\n}\n\n.alert-status-success {\n  color: #28a745;\n}\n\n.alert-status-info:before{\n  content: \"\\f129\";\n  color: #17a2b8;\n}\n\n.alert-status-info {\n  color: #17a2b8;\n}\n\n.alert-status-pending:before{\n  content: \"\\f017\";\n  color: #ffc107;\n}\n\n.alert-status-pending {\n  color: #ffc107;\n}\n\n/*.notifications-scroll-area {*/\n  /*height: 200px;*/\n  /*position: relative;*/\n  /*overflow: auto;*/\n/*}*/\n\n.notifications-hdr {\n  position: relative;\n  display: flex;\n  -moz-box-align: center;\n  align-items: center;\n  font-size: 0.875rem;\n  height: 2.5rem;\n  min-height: 2.5rem;\n  color: rgba(128, 128, 128, 0.8);\n  border-bottom: 1px solid rgba(0, 0, 0, 0.3);\n  box-shadow: rgba(0, 0, 0, 0.3) 0px 0px 3px;\n  flex-direction: row;\n  padding-left: 10px;\n}\n\n.hdr-block-right {\n  position: absolute;\n  right: 1rem;\n  /*font-size: 1.125rem;*/\n  display: inline-flex;\n}\n\n.hdr-badge {\n  transition: all 0.3s ease 0s;\n  display: inline-flex;\n  -moz-box-pack: center;\n  justify-content: center;\n  -moz-box-align: center;\n  align-items: center;\n  font-size: 0.5rem;\n  margin-left: 0.25rem;\n  border-radius: 50%;\n  height: 16px;\n  width: 16px;\n  color: rgba(255, 255, 255, 0.4);\n  background-color: rgba(255, 255, 255, 0.2);\n}\n\n.hdr-block-btn {\n  transition: color 0.2s ease 0s;\n  display: flex;\n  -moz-box-align: center;\n  align-items: center;\n  height: calc(-1px + 2rem);\n  padding: 0px 1rem;\n  cursor: pointer;\n  font-weight: 600;\n  /*color: rgb(255, 255, 255);*/\n  /*background-color: rgb(36, 40, 42);*/\n}\n\n.alert-block-btn {\n  cursor: pointer;\n  font-weight: 600;\n}\n\n.notifications-scroll-area {\n  /*background-color: rgb(36, 40, 42);*/\n  /*color: rgba(255, 255, 255, 0.8);*/\n  font-family: Menlo, monospace;\n  font-size: 14px;\n  display: flex;\n  flex-direction: column;\n  /*border-color: rgb(25, 28, 29);*/\n  max-height: calc(100% - 2.5rem);\n  line-height: 1rem;\n  /*max-height: 100%;*/\n  width: 100%;\n  height: 100%;\n}\n\n.notifications-stack {\n  -moz-box-flex: 1;\n  flex-grow: 1;\n  overflow: hidden auto;\n  /*white-space: pre-wrap;*/\n}\n\n.notification-it {\n  position: relative;\n  display: flex;\n  background-color: transparent;\n  border-top: 1px solid rgb(255, 255, 255);\n  border-bottom: 1px solid rgb(255, 255, 255);\n  margin-top: -1px;\n  margin-bottom: 0px;\n  padding-left: 10px;\n  box-sizing: border-box;\n}\n\n.notification-it.info {\n  color: #17a2b8;\n}\n\n.notification-it.success {\n  color: #28a745;\n}\n\n.notification-it.danger {\n  color: #dc3545;\n}\n\n.notification-it:before{\n  font-family: FontAwesome;\n  font-size: 1em;\n  padding-right: 0.75em;\n  width: 1em;\n  display: inline-block;\n  text-align: center;\n}\n\n.notification-it.info:before {\n  color: #17a2b8;\n  content: \"\\f129\";\n}\n\n.notification-it.success:before {\n  color: #28a745;\n  content: \"\\f058\";\n}\n\n.notification-it.danger:before {\n  color: #dc3545;\n  content: \"\\f071\";\n}\n\n.navbar-light .navbar-nav .nav-link.dimmed {\n  color: rgba(0,0,0,.3);\n}\n\n.inline-cont{\n  display: flex;\n  flex-wrap: nowrap;\n  align-items: stretch;\n}\n\n.inline-cont>* {\n  /*flex: 1 1 160px;*/\n  flex: 0 1 auto;\n}\n\n.inline-cont-item{\n  flex: 0 1 auto;\n  justify-content:left!important;\n  white-space: normal;\n}\n\n.inline-cont-item2 {\n  justify-content:left!important;\n  width: 100%!important;\n  white-space: normal;\n}\n"; });
define('services/validation-service',[], function () {
  "use strict";
});
define('services/socket-service',['exports', 'aurelia-framework', 'aurelia-event-aggregator', './alert-service', 'socket.io-client', '../config'], function (exports, _aureliaFramework, _aureliaEventAggregator, _alertService, _socket, _config) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.SocketService = undefined;

  var _socket2 = _interopRequireDefault(_socket);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      default: obj
    };
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _dec, _class;

  var log = _aureliaFramework.LogManager.getLogger('SocketService');

  var SocketService = exports.SocketService = (_dec = (0, _aureliaFramework.inject)(_aureliaEventAggregator.EventAggregator, _alertService.AlertService), _dec(_class = function () {
    function SocketService(eventAggregator, alertService) {
      _classCallCheck(this, SocketService);

      this.eventAggregator = eventAggregator;
      this.alertService = alertService;

      this.socket = _socket2.default.connect(_config.Config.getUrl());
    }

    SocketService.prototype.subscribe = function subscribe() {
      var _this = this;

      log.info('subscribe socket.connected', this.socket.connected);

      if (!this.subscribed) {
        this.socket.on('chainblock', function (o) {
          log.debug('chainblock', o);

          _this.alertService.success('new block ' + o.number + ' on ' + o.channel_id, "PUT");
          _this.eventAggregator.publish('block', o);
        });
      }

      this.subscribed = true;
    };

    SocketService.prototype.disconnect = function disconnect() {
      this.subscribed = false;
      this.socket.disconnect();
    };

    return SocketService;
  }()) || _class);
});
define('services/identity-service',['exports', 'aurelia-framework', 'aurelia-fetch-client', './alert-service', './config-service', '../config'], function (exports, _aureliaFramework, _aureliaFetchClient, _alertService, _configService, _config) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.IdentityService = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _dec, _class;

  var log = _aureliaFramework.LogManager.getLogger('IdentityService');

  var baseUrl = _config.Config.getUrl('users');

  var IdentityService = exports.IdentityService = (_dec = (0, _aureliaFramework.inject)(_aureliaFramework.Aurelia, _aureliaFetchClient.HttpClient, _configService.ConfigService), _dec(_class = function () {
    function IdentityService(aurelia, http, configService) {
      var _this = this;

      _classCallCheck(this, IdentityService);

      this.aurelia = aurelia;
      this.http = http;
      this.configService = configService;

      this.configService.get().then(function (config) {
        _this.org = config.org;
      });
    }

    IdentityService.getJwt = function getJwt(org, username) {
      return localStorage.getItem(IdentityService.key(org, username));
    };

    IdentityService.key = function key(org, username) {
      return 'jwt' + (org ? org.name + username : '');
    };

    IdentityService.setJwt = function setJwt(jwt, org, username) {
      localStorage.setItem(IdentityService.key(org, username), jwt);
    };

    IdentityService.prototype.enroll = function enroll(username, password, org) {
      var _this2 = this;

      var jwt = IdentityService.getJwt(org, username);
      if (jwt) {
        log.debug('already enrolled ' + org.name + ' ' + username, jwt);
        return Promise.resolve();
      }

      var url = org ? org.url + '/users' : baseUrl;

      var params = {
        username: username,
        password: password
      };

      return new Promise(function (resolve, reject) {
        _this2.http.fetch(url, {
          method: 'post',
          body: (0, _aureliaFetchClient.json)(params)
        }).then(function (response) {
          response.json().then(function (j) {
            if (!response.ok) {
              reject(new Error('cannot enroll ' + response.status + ' ' + j));
            } else {
              log.debug(j);

              IdentityService.setJwt(j, org, username);

              _this2.username = username;

              if (!org) {
                _this2.aurelia.setRoot('app');
              }

              resolve();
            }
          });
        }).catch(function (err) {
          reject(err);
        });
      });
    };

    IdentityService.prototype.logout = function logout() {
      localStorage.clear();
      return this.aurelia.setRoot('login');
    };

    return IdentityService;
  }()) || _class);
});
define('services/file-service',['exports', 'aurelia-framework'], function (exports, _aureliaFramework) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.FileService = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var log = _aureliaFramework.LogManager.getLogger('FileService');

  var FileService = exports.FileService = function FileService() {
    _classCallCheck(this, FileService);
  };
});
define('services/config-service',['exports', 'aurelia-framework', 'aurelia-fetch-client', '../config'], function (exports, _aureliaFramework, _aureliaFetchClient, _config) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.ConfigService = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _dec, _class;

  var log = _aureliaFramework.LogManager.getLogger('ConfigService');

  var ConfigService = exports.ConfigService = (_dec = (0, _aureliaFramework.inject)(_aureliaFetchClient.HttpClient), _dec(_class = function () {
    function ConfigService(http) {
      _classCallCheck(this, ConfigService);

      this.http = http;
    }

    ConfigService.prototype.get = function get() {
      var _this = this;

      return new Promise(function (resolve, reject) {
        _this.http.fetch(_config.Config.getUrl('mspid')).then(function (response) {
          return response.json();
        }).then(function (mspid) {
          log.debug('mspid', mspid);
          _this.config = {
            org: mspid
          };

          resolve(_this.config);
        }).catch(function (err) {
          reject(err);
        });
      });
    };

    return ConfigService;
  }()) || _class);
});
define('services/chaincode-service',['exports', 'aurelia-framework', 'aurelia-fetch-client', './identity-service', './alert-service', '../config'], function (exports, _aureliaFramework, _aureliaFetchClient, _identityService, _alertService, _config) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.ChaincodeService = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _dec, _class;

  var log = _aureliaFramework.LogManager.getLogger('ChaincodeService');

  var baseUrl = _config.Config.getUrl('channels/');

  var ChaincodeService = exports.ChaincodeService = (_dec = (0, _aureliaFramework.inject)(_aureliaFetchClient.HttpClient, _identityService.IdentityService, _alertService.AlertService), _dec(_class = function () {
    function ChaincodeService(http, identityService, alertService) {
      _classCallCheck(this, ChaincodeService);

      this.identityService = identityService;
      this.http = http;
      this.alertService = alertService;
      this.mspID = this.identityService.org;
    }

    ChaincodeService.prototype.fetch = function fetch(url, params, method, org, username) {
      var _this = this;

      log.debug('fetch', params);
      log.debug(JSON.stringify(params));

      return new Promise(function (resolve, reject) {
        var jwt = _identityService.IdentityService.getJwt(org, username);

        var promise = void 0;

        if (method === 'get') {
          var query = '';
          if (params) {
            query = '?' + Object.keys(params).map(function (k) {
              return encodeURIComponent(k) + '=' + encodeURIComponent(params[k]);
            }).join('&');
          }

          promise = _this.http.fetch('' + url + query, {
            headers: {
              'Authorization': 'Bearer ' + jwt
            }
          });
        } else {
          promise = _this.http.fetch(url, {
            method: method,
            body: (0, _aureliaFetchClient.json)(params),
            headers: {
              'Authorization': 'Bearer ' + jwt
            }
          });
        }

        promise.then(function (response) {
          if (response.status === 401) {
            _this.alertService.info('session expired, logging you out');
            _this.identityService.logout();
            reject(new Error('Session expired, logging you out'));
          }
          response.json().then(function (j) {
            log.debug('fetch', j);

            if (!response.ok) {
              var msg = response.statusText + ' ' + j;

              if (response.status === 401) {
                _this.alertService.info('session expired, logging you out');
                _this.identityService.logout();
              } else {
                _this.alertService.error(msg);
              }

              reject(new Error(msg));
            } else {
              resolve(j);
            }
          });
        }).catch(function (err) {
          _this.alertService.error('caught ' + err);
          reject(err);
        });
      });
    };

    ChaincodeService.prototype.getBilateralChannels = function getBilateralChannels() {
      var _this2 = this;

      return this.getChannels().then(function (channels) {
        return channels.filter(function (channel) {
          var orgs = channel.split('-');
          return orgs.length === 2 && (orgs[0] === _this2.identityService.org || orgs[1] === _this2.identityService.org);
        });
      });
    };

    ChaincodeService.prototype.getChannels = function getChannels(org, username) {
      var _this3 = this;

      log.debug('getChannels ' + org + ' ' + username);

      var url = baseUrl;

      return new Promise(function (resolve, reject) {
        _this3.fetch(url, null, 'get', org, username).then(function (j) {
          var channels = j.map(function (o) {
            return o.channel_id;
          });

          resolve(channels);
        }).catch(function (err) {
          reject(err);
        });
      });
    };

    ChaincodeService.prototype.query = function query(channel, chaincode, func, args, org, username) {
      var _this4 = this;

      log.debug('query channel=' + channel + ' chaincode=' + chaincode + ' func=' + func + ' ' + org + ' ' + username, args);

      var url = org ? org.url + '/channels/' : baseUrl;

      var params = {
        fcn: func,
        args: (0, _aureliaFetchClient.json)(args)
      };

      return new Promise(function (resolve, reject) {
        _this4.alertService.pending('data fetching ..');

        _this4.fetch('' + url + channel + '/chaincodes/' + chaincode, params, 'get', org, username).then(function (j) {
          log.debug('query result:', j);
          _this4.alertService.success('data fetched successfully');
          var result = JSON.parse(j[0]);
          log.debug('result:', result);
          resolve(result);
        }).catch(function (err) {
          reject(err);
        });
      });
    };

    ChaincodeService.prototype.getOrgs = function getOrgs(channel, org, username) {
      var _this5 = this;

      log.debug('get ORGS for channel=' + channel);

      var url = org ? org.url + '/channels/' : baseUrl;

      return new Promise(function (resolve, reject) {
        _this5.fetch('' + url + channel + '/orgs', undefined, 'get', org, username).then(function (j) {
          resolve(j);
        }).catch(function (err) {
          reject(err);
        });
      });
    };

    ChaincodeService.prototype.invoke = function invoke(channel, chaincode, func, args, org, username) {
      var _this6 = this;

      log.debug('invoke channel=' + channel + ' chaincode=' + chaincode + ' func=' + func + ' ' + org + ' ' + username, args);

      var url = org ? org.url + '/channels/' : baseUrl;

      var params = {
        fcn: func,
        args: args
      };

      return new Promise(function (resolve, reject) {
        _this6.alertService.pending('data updating ..', 'PUT');
        _this6.fetch('' + url + channel + '/chaincodes/' + chaincode, params, 'post', org, username).then(function (j) {
          resolve(j.transaction);
        }).catch(function (err) {
          reject(err);
        });
      });
    };

    ChaincodeService.prototype.invokeWithTransient = function invokeWithTransient(channel, chaincode, func, args, transient, org, username) {
      var _this7 = this;

      log.debug('invoke channel=' + channel + ' chaincode=' + chaincode + ' func=' + func + ' ' + org + ' ' + username, transient);

      var url = org ? org.url + '/channels/' : baseUrl;

      var params = {
        fcn: func,
        args: args,
        transientMap: transient
      };

      return new Promise(function (resolve, reject) {
        _this7.alertService.pending('data updating ..', 'PUT');
        _this7.fetch('' + url + channel + '/chaincodes/' + chaincode, params, 'post', org, username).then(function (j) {
          resolve(j.transaction);
        }).catch(function (err) {
          reject(err);
        });
      });
    };

    return ChaincodeService;
  }()) || _class);
});
define('services/alert-service',['exports', 'aurelia-framework'], function (exports, _aureliaFramework) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.AlertService = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var log = _aureliaFramework.LogManager.getLogger('AlertService');

  var _messageStackMaxSize = 50;

  var AlertService = exports.AlertService = function () {
    function AlertService() {
      var _this = this;

      _classCallCheck(this, AlertService);

      this.onNewMessage = function (message) {
        var _pending = _this._alertMessages.find(function (x) {
          return x.type === 'pending' && x.scope === message.scope;
        });

        if (_this._alertMessages.length > 0 && message.type === _this._alertMessages[0].type && message.type === 'success' && message.message === _this._alertMessages[0].message && message.scope === 'GET') {
          _this._alertMessages[0].time = new Date();
        } else if (_pending && message.type === 'pending') {
          _pending.time = new Date();
        } else if (_pending && message.type !== 'pending') {
          _this._alertMessages = _this._alertMessages.filter(function (x) {
            return !(x.type === 'pending' && x.scope === message.scope);
          });

          if (_this._alertMessages.length > 0 && message.type === _this._alertMessages[0].type && message.type === 'success' && message.message === _this._alertMessages[0].message && message.scope === 'GET') {
            _this._alertMessages[0].time = new Date();
          } else {
            _this._alertMessages.unshift(message);
          }
        } else {
          _this._alertMessages.unshift(message);
          if (_this._alertMessages.length > _messageStackMaxSize) {
            _this._alertMessages.splice(-1, 1);
          }
        }
      };

      this._alertMessages = [];
    }

    AlertService.prototype.pending = function pending(m) {
      var scope = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 'GET';
      var title = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : 'Awaiting..';

      this.onNewMessage({ type: 'pending', title: title, message: m, time: new Date(), scope: scope });
    };

    AlertService.prototype.info = function info(m) {
      var scope = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 'GET';
      var title = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : 'Information';

      this.onNewMessage({ type: 'info', title: title, message: m, time: new Date(), scope: scope });
    };

    AlertService.prototype.error = function error(m) {
      var scope = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 'GET';
      var title = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : 'Error';

      this.onNewMessage({ type: 'danger', title: title, message: m, time: new Date(), scope: scope });
    };

    AlertService.prototype.success = function success(m) {
      var scope = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 'GET';
      var title = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : 'Success';

      this.onNewMessage({ type: 'success', title: title, message: m, time: new Date(), scope: scope });
    };

    return AlertService;
  }();
});
define('resources/index',["exports"], function (exports) {
  "use strict";

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.configure = configure;
  function configure(config) {}
});
define('text!resources/elements/widgets/table-view-text.html', ['module'], function(module) { module.exports = "<template bindable=\"\">\n  <require from=\"./../field-value-converters\"></require>\n\n  text11\n</template>\n"; });
define('text!resources/elements/widgets/table-view-key.html', ['module'], function(module) { module.exports = "<template bindable=\"\">\n  <require from=\"./key\"></require>\n\n\n</template>\n"; });
define('resources/elements/widget-multisel-list',['exports', 'aurelia-framework'], function (exports, _aureliaFramework) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.WidgetMultiselListCustomElement = undefined;

  function _initDefineProp(target, property, descriptor, context) {
    if (!descriptor) return;
    Object.defineProperty(target, property, {
      enumerable: descriptor.enumerable,
      configurable: descriptor.configurable,
      writable: descriptor.writable,
      value: descriptor.initializer ? descriptor.initializer.call(context) : void 0
    });
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  function _applyDecoratedDescriptor(target, property, decorators, descriptor, context) {
    var desc = {};
    Object['ke' + 'ys'](descriptor).forEach(function (key) {
      desc[key] = descriptor[key];
    });
    desc.enumerable = !!desc.enumerable;
    desc.configurable = !!desc.configurable;

    if ('value' in desc || desc.initializer) {
      desc.writable = true;
    }

    desc = decorators.slice().reverse().reduce(function (desc, decorator) {
      return decorator(target, property, desc) || desc;
    }, desc);

    if (context && desc.initializer !== void 0) {
      desc.value = desc.initializer ? desc.initializer.call(context) : void 0;
      desc.initializer = undefined;
    }

    if (desc.initializer === void 0) {
      Object['define' + 'Property'](target, property, desc);
      desc = null;
    }

    return desc;
  }

  function _initializerWarningHelper(descriptor, context) {
    throw new Error('Decorating class property failed. Please ensure that transform-class-properties is enabled.');
  }

  var _desc, _value, _class, _descriptor, _descriptor2, _descriptor3, _descriptor4;

  var WidgetMultiselListCustomElement = exports.WidgetMultiselListCustomElement = (_class = function () {
    function WidgetMultiselListCustomElement() {
      _classCallCheck(this, WidgetMultiselListCustomElement);

      _initDefineProp(this, 'options', _descriptor, this);

      _initDefineProp(this, 'selectedChangeCallback', _descriptor2, this);

      _initDefineProp(this, 'onReadError', _descriptor3, this);

      _initDefineProp(this, 'fixHeight', _descriptor4, this);

      this.loading = false;
    }

    WidgetMultiselListCustomElement.prototype.dismissFormClicked = function dismissFormClicked($event) {
      console.log('dismissFormClicked');

      if (this.dismissFormCallback) this.dismissFormCallback();
    };

    WidgetMultiselListCustomElement.prototype.optionClicked = function optionClicked($o) {
      $o.selected = !$o.selected;

      if (this.selectedChangeCallback != null) {
        this.selectedChangeCallback({ data: this.options.filter(function (x) {
            return x.selected;
          }) });
      }
    };

    return WidgetMultiselListCustomElement;
  }(), (_descriptor = _applyDecoratedDescriptor(_class.prototype, 'options', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return [];
    }
  }), _descriptor2 = _applyDecoratedDescriptor(_class.prototype, 'selectedChangeCallback', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor3 = _applyDecoratedDescriptor(_class.prototype, 'onReadError', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor4 = _applyDecoratedDescriptor(_class.prototype, 'fixHeight', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  })), _class);
});
define('text!resources/elements/widget-multisel-list.html', ['module'], function(module) { module.exports = "<template>\n\n  <div class=\"container\">\n    <div class=\"row\">\n      <div class=\"col\">\n        <div class=\"list-group mt-12\" style.bind=\"fixHeight != null ? 'height: ' + fixHeight + 'px; overflow-y: scroll;' : ''\">\n\n          <a repeat.for=\"$o of options\" click.trigger=\"optionClicked($o)\" href=\"#\" class.bind=\"'list-group-item list-group-item-action ' + ($o.selected ? 'widget-selected' : '')\" >\n            <div class=\"custom-control custom-checkbox float-left\">\n              <input type=\"checkbox\" class=\"custom-control-input\" id.bind=\"'option-' + $o.id\" checked.bind=\"$o.selected\" />\n              <label class=\"custom-control-label\" for.bind=\"'option-' + $o.id\">${$o.title}</label>\n              <!--for.bind=\"${‘option-id-’+{o.id}}\"-->\n            </div>\n          </a>\n\n        </div>\n      </div>\n    </div>\n  </div>\n\n\n</template>\n"; });
define('resources/elements/widget-entity-crud',["exports", "aurelia-framework"], function (exports, _aureliaFramework) {
  "use strict";

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.WidgetEntityCrudCustomElement = undefined;

  function _initDefineProp(target, property, descriptor, context) {
    if (!descriptor) return;
    Object.defineProperty(target, property, {
      enumerable: descriptor.enumerable,
      configurable: descriptor.configurable,
      writable: descriptor.writable,
      value: descriptor.initializer ? descriptor.initializer.call(context) : void 0
    });
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  function _applyDecoratedDescriptor(target, property, decorators, descriptor, context) {
    var desc = {};
    Object['ke' + 'ys'](descriptor).forEach(function (key) {
      desc[key] = descriptor[key];
    });
    desc.enumerable = !!desc.enumerable;
    desc.configurable = !!desc.configurable;

    if ('value' in desc || desc.initializer) {
      desc.writable = true;
    }

    desc = decorators.slice().reverse().reduce(function (desc, decorator) {
      return decorator(target, property, desc) || desc;
    }, desc);

    if (context && desc.initializer !== void 0) {
      desc.value = desc.initializer ? desc.initializer.call(context) : void 0;
      desc.initializer = undefined;
    }

    if (desc.initializer === void 0) {
      Object['define' + 'Property'](target, property, desc);
      desc = null;
    }

    return desc;
  }

  function _initializerWarningHelper(descriptor, context) {
    throw new Error('Decorating class property failed. Please ensure that transform-class-properties is enabled.');
  }

  var _desc, _value, _class, _descriptor, _descriptor2, _descriptor3, _descriptor4, _descriptor5, _descriptor6, _descriptor7, _descriptor8, _descriptor9, _descriptor10, _descriptor11, _descriptor12, _descriptor13;

  var WidgetEntityCrudCustomElement = exports.WidgetEntityCrudCustomElement = (_class = function () {
    function WidgetEntityCrudCustomElement() {
      _classCallCheck(this, WidgetEntityCrudCustomElement);

      _initDefineProp(this, "showForm", _descriptor, this);

      _initDefineProp(this, "showViewOnly", _descriptor2, this);

      _initDefineProp(this, "entityTitle", _descriptor3, this);

      _initDefineProp(this, "buttonAVisible", _descriptor4, this);

      _initDefineProp(this, "buttonAName", _descriptor5, this);

      _initDefineProp(this, "buttonACallback", _descriptor6, this);

      _initDefineProp(this, "buttonBVisible", _descriptor7, this);

      _initDefineProp(this, "buttonBName", _descriptor8, this);

      _initDefineProp(this, "buttonBCallback", _descriptor9, this);

      _initDefineProp(this, "buttonCVisible", _descriptor10, this);

      _initDefineProp(this, "buttonCName", _descriptor11, this);

      _initDefineProp(this, "buttonCCallback", _descriptor12, this);

      _initDefineProp(this, "backActionCallback", _descriptor13, this);
    }

    WidgetEntityCrudCustomElement.prototype.backAction = function backAction($event) {
      if (this.backActionCallback) this.backActionCallback();
    };

    WidgetEntityCrudCustomElement.prototype.buttonAClicked = function buttonAClicked() {
      if (this.buttonACallback) this.buttonACallback();
    };

    WidgetEntityCrudCustomElement.prototype.buttonBClicked = function buttonBClicked($event) {
      if (this.buttonBCallback) this.buttonBCallback();
    };

    WidgetEntityCrudCustomElement.prototype.buttonCClicked = function buttonCClicked($event) {
      if (this.buttonCCallback) this.buttonCCallback();
    };

    return WidgetEntityCrudCustomElement;
  }(), (_descriptor = _applyDecoratedDescriptor(_class.prototype, "showForm", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return false;
    }
  }), _descriptor2 = _applyDecoratedDescriptor(_class.prototype, "showViewOnly", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return false;
    }
  }), _descriptor3 = _applyDecoratedDescriptor(_class.prototype, "entityTitle", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor4 = _applyDecoratedDescriptor(_class.prototype, "buttonAVisible", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return true;
    }
  }), _descriptor5 = _applyDecoratedDescriptor(_class.prototype, "buttonAName", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return "save";
    }
  }), _descriptor6 = _applyDecoratedDescriptor(_class.prototype, "buttonACallback", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor7 = _applyDecoratedDescriptor(_class.prototype, "buttonBVisible", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return false;
    }
  }), _descriptor8 = _applyDecoratedDescriptor(_class.prototype, "buttonBName", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return "cancel";
    }
  }), _descriptor9 = _applyDecoratedDescriptor(_class.prototype, "buttonBCallback", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor10 = _applyDecoratedDescriptor(_class.prototype, "buttonCVisible", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return false;
    }
  }), _descriptor11 = _applyDecoratedDescriptor(_class.prototype, "buttonCName", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return "delete";
    }
  }), _descriptor12 = _applyDecoratedDescriptor(_class.prototype, "buttonCCallback", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor13 = _applyDecoratedDescriptor(_class.prototype, "backActionCallback", [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  })), _class);
});
define('text!resources/elements/widget-entity-crud.html', ['module'], function(module) { module.exports = "<template class=\"flex-fill-column\">\n\n  <div class=\"card flex-fill-column\" show.bind=\"!showForm && !showViewOnly\">\n    <div class=\"card-body aut-table-card\">\n      <!--<span class=\"aut-table-card-title\" if.bind=\"entityTitle\" t.bind=\"entityTitle\"></span>-->\n      <template replaceable part=\"handy-table-part\">Table Placeholder.</template>\n    </div>\n  </div>\n\n  <!--<div class=\"card aut-splitter-card\" >-->\n    <!--<div class=\"card-body\">-->\n    <!--</div>-->\n  <!--</div>-->\n\n  <div class=\"card flex-fill-column aut-form-card-container\" show.bind=\"showForm\">\n    <span if.bind=\"backActionCallback\" class=\"aut-form-card-close\" click.trigger=\"backAction($event)\">\n      <!--<span class=\"aut-tooltip\" t=\"closeWindow\"></span>-->\n      <i class=\"fa fa-arrow-circle-left fa-2x\"></i>\n    </span>\n\n    <div class=\"card-body aut-form-card\">\n      <!--<h5 class=\"card-title\"></h5>-->\n      <form submit.delegate=\"buttonAClicked()\" >\n        <template replaceable part=\"handy-form-part\">Form placeholder</template>\n\n        <div class=\"form-group mt-1\">\n          <div class=\"d-inline\" if.bind=\"buttonAVisible\">\n            <button type=\"submit\" class=\"btn btn-success\" t=\"${buttonAName}\">save</button>\n          </div>\n          <div class=\"d-inline\" if.bind=\"buttonBVisible\">\n            <button type=\"button\" class=\"btn btn-success\" click.trigger=\"buttonBClicked($event)\" t=\"${buttonBName}\">cancel</button>\n          </div>\n          <div class=\"d-inline\" if.bind=\"buttonCVisible\">\n            <button class=\"btn btn-danger float-right\" click.trigger=\"buttonCClicked($event)\" t=\"${buttonCName}\">delete</button>\n          </div>\n        </div>\n\n      </form>\n\n    </div>\n  </div>\n\n  <div class=\"card aut-form-card-container\" show.bind=\"showViewOnly\">\n    <span if.bind=\"backActionCallback\" class=\"aut-form-card-close\" click.trigger=\"backAction($event)\">\n      <!--<span class=\"aut-tooltip\" t=\"closeWindow\"></span>-->\n      <i class=\"fa fa-arrow-circle-left fa-2x\"></i>\n    </span>\n\n    <div class=\"card-body aut-form-card\">\n      <template replaceable part=\"handy-viewonly-part\">View Only placeholder</template>\n    </div>\n  </div>\n\n</template>\n"; });
define('resources/elements/spinner',['exports', 'aurelia-framework'], function (exports, _aureliaFramework) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.SpinnerCustomElement = undefined;

  function _initDefineProp(target, property, descriptor, context) {
    if (!descriptor) return;
    Object.defineProperty(target, property, {
      enumerable: descriptor.enumerable,
      configurable: descriptor.configurable,
      writable: descriptor.writable,
      value: descriptor.initializer ? descriptor.initializer.call(context) : void 0
    });
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  function _applyDecoratedDescriptor(target, property, decorators, descriptor, context) {
    var desc = {};
    Object['ke' + 'ys'](descriptor).forEach(function (key) {
      desc[key] = descriptor[key];
    });
    desc.enumerable = !!desc.enumerable;
    desc.configurable = !!desc.configurable;

    if ('value' in desc || desc.initializer) {
      desc.writable = true;
    }

    desc = decorators.slice().reverse().reduce(function (desc, decorator) {
      return decorator(target, property, desc) || desc;
    }, desc);

    if (context && desc.initializer !== void 0) {
      desc.value = desc.initializer ? desc.initializer.call(context) : void 0;
      desc.initializer = undefined;
    }

    if (desc.initializer === void 0) {
      Object['define' + 'Property'](target, property, desc);
      desc = null;
    }

    return desc;
  }

  function _initializerWarningHelper(descriptor, context) {
    throw new Error('Decorating class property failed. Please ensure that transform-class-properties is enabled.');
  }

  var _desc, _value, _class, _descriptor, _descriptor2;

  var SpinnerCustomElement = exports.SpinnerCustomElement = (_class = function SpinnerCustomElement() {
    _classCallCheck(this, SpinnerCustomElement);

    _initDefineProp(this, 'busy', _descriptor, this);

    _initDefineProp(this, 'mode', _descriptor2, this);
  }, (_descriptor = _applyDecoratedDescriptor(_class.prototype, 'busy', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return false;
    }
  }), _descriptor2 = _applyDecoratedDescriptor(_class.prototype, 'mode', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return 'context';
    }
  })), _class);
});
define('text!resources/elements/spinner.html', ['module'], function(module) { module.exports = "<template>\n  <!--show.bind=\"busy\"-->\n  <div show.bind=\"busy\">\n    <div class=\"progress-line\"></div>\n    <!--<div class=\"spinner-context\"></div>-->\n    <div class=\"spinner-blocker-context\"></div>\n  </div>\n</template>\n"; });
define('resources/elements/key',['exports', 'aurelia-framework'], function (exports, _aureliaFramework) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.KeyCustomElement = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _dec, _class;

  var KeyCustomElement = exports.KeyCustomElement = (_dec = (0, _aureliaFramework.bindable)({ name: 'o', attribute: 'data' }), _dec(_class = function () {
    function KeyCustomElement() {
      _classCallCheck(this, KeyCustomElement);
    }

    KeyCustomElement.prototype.oChanged = function oChanged() {
      if (this.o) {
        var key = this.o;
        var parts = key.split('\0');
        if (parts.length > 2) {
          this.objectType = parts[1];
          this.id = parts[2];
        } else {
          this.id = key;
        }
      }
    };

    return KeyCustomElement;
  }()) || _class);
});
define('text!resources/elements/key.html', ['module'], function(module) { module.exports = "<template>\n  <abbr title=\"key=${o} objectType=${objectType} id=${id}\">${id}</abbr>\n</template>\n"; });
define('resources/elements/handy-table',['exports', 'aurelia-framework', './column', '../../services/identity-service', '../../services/chaincode-service', 'aurelia-validation', 'aurelia-event-aggregator', './expression-evaluator'], function (exports, _aureliaFramework, _column, _identityService, _chaincodeService, _aureliaValidation, _aureliaEventAggregator, _expressionEvaluator) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.HandyTableCustomElement = undefined;

  function _initDefineProp(target, property, descriptor, context) {
    if (!descriptor) return;
    Object.defineProperty(target, property, {
      enumerable: descriptor.enumerable,
      configurable: descriptor.configurable,
      writable: descriptor.writable,
      value: descriptor.initializer ? descriptor.initializer.call(context) : void 0
    });
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  function _applyDecoratedDescriptor(target, property, decorators, descriptor, context) {
    var desc = {};
    Object['ke' + 'ys'](descriptor).forEach(function (key) {
      desc[key] = descriptor[key];
    });
    desc.enumerable = !!desc.enumerable;
    desc.configurable = !!desc.configurable;

    if ('value' in desc || desc.initializer) {
      desc.writable = true;
    }

    desc = decorators.slice().reverse().reduce(function (desc, decorator) {
      return decorator(target, property, desc) || desc;
    }, desc);

    if (context && desc.initializer !== void 0) {
      desc.value = desc.initializer ? desc.initializer.call(context) : void 0;
      desc.initializer = undefined;
    }

    if (desc.initializer === void 0) {
      Object['define' + 'Property'](target, property, desc);
      desc = null;
    }

    return desc;
  }

  function _initializerWarningHelper(descriptor, context) {
    throw new Error('Decorating class property failed. Please ensure that transform-class-properties is enabled.');
  }

  var _dec, _dec2, _class, _desc, _value, _class2, _descriptor, _descriptor2, _descriptor3, _descriptor4, _descriptor5, _descriptor6, _descriptor7, _descriptor8, _descriptor9, _descriptor10, _descriptor11, _descriptor12, _descriptor13, _descriptor14, _descriptor15, _descriptor16, _descriptor17, _descriptor18, _descriptor19, _descriptor20, _descriptor21;

  var HandyTableCustomElement = exports.HandyTableCustomElement = (_dec = (0, _aureliaFramework.inject)(_aureliaEventAggregator.EventAggregator, _expressionEvaluator.ExpressionEvaluator), _dec2 = (0, _aureliaFramework.children)('column'), _dec(_class = (_class2 = function () {
    function HandyTableCustomElement(eventAggregator, evaluator) {
      var _this = this;

      _classCallCheck(this, HandyTableCustomElement);

      _initDefineProp(this, 'tabident', _descriptor, this);

      _initDefineProp(this, 'columns', _descriptor2, this);

      _initDefineProp(this, 'canHideColumns', _descriptor3, this);

      _initDefineProp(this, 'canFilterColumns', _descriptor4, this);

      this.visiblecolumns = [];
      this.filteredColumns = [];

      _initDefineProp(this, 'pageable', _descriptor5, this);

      _initDefineProp(this, 'pageSize', _descriptor6, this);

      _initDefineProp(this, 'page', _descriptor7, this);

      _initDefineProp(this, 'pagerSize', _descriptor8, this);

      this.loading = false;

      _initDefineProp(this, 'loadingMessage', _descriptor9, this);

      _initDefineProp(this, 'loadingDiv', _descriptor10, this);

      _initDefineProp(this, 'readData', _descriptor11, this);

      _initDefineProp(this, 'dataSet', _descriptor12, this);

      _initDefineProp(this, 'onReadError', _descriptor13, this);

      _initDefineProp(this, 'selectedCallback', _descriptor14, this);

      _initDefineProp(this, 'createNewCallback', _descriptor15, this);

      _initDefineProp(this, 'canCreate', _descriptor16, this);

      _initDefineProp(this, 'canDelete', _descriptor17, this);

      _initDefineProp(this, 'canCancelFilter', _descriptor18, this);

      _initDefineProp(this, 'minHeight', _descriptor19, this);

      _initDefineProp(this, 'pickerDateTime1', _descriptor20, this);

      _initDefineProp(this, 'pickerDateTime2', _descriptor21, this);

      this.dataList = [];
      this.skipRowClick = false;
      this.localStoreKey = '_profile.h-tab.';
      this.localStoreFilterSubKey = '.filterst';
      this.sortColumn = undefined;

      this.sortColumnData = function (a, b, order) {
        var vala = _this.sortColumn.field ? _this.evaluator.evaluateInterpolation('${' + _this.sortColumn.field + '}', a) : _this.sortColumn.sortTextView({ data: a });
        var valb = _this.sortColumn.field ? _this.evaluator.evaluateInterpolation('${' + _this.sortColumn.field + '}', b) : _this.sortColumn.sortTextView({ data: b });

        if (order === 1) {
          if (vala < valb) {
            return -1;
          }
          if (vala > valb) {
            return 1;
          }
        }
        if (order === -1) {
          if (vala < valb) {
            return 1;
          }
          if (vala > valb) {
            return -1;
          }
        }
        return 0;
      };

      this.eventAggregator = eventAggregator;
      this.evaluator = evaluator;
    }

    HandyTableCustomElement.prototype.canFilter = function canFilter() {
      return this.readData;
    };

    HandyTableCustomElement.prototype.getFilters = function getFilters() {
      var filters = {
        type: "filter",
        expressions: []
      };

      this.columns.forEach(function (entry) {
        if (entry.filterActive) {
          var _filters$expressions;

          (_filters$expressions = filters.expressions).push.apply(_filters$expressions, entry.filterExpression);
        }
      });

      filters.expressions = filters.expressions.filter(function (x) {
        return x && (x.value || x.values);
      });


      return filters;
    };

    HandyTableCustomElement.prototype.getData = function getData() {
      var _this2 = this;

      if (!this.readData) throw new Error("No readData method specified for table");

      this.loading = true;

      this.readData({ filter: this.getFilters() }).then(function (result) {
        _this2.dataList = result;

        _this2.loading = false;
      }).catch(function (error) {
        console.log(error);

        if (_this2.onReadError) _this2.onReadError(error);

        _this2.loading = false;
      });
    };

    HandyTableCustomElement.prototype.sort = function sort(column) {
      this.sortColumn = column;
    };

    HandyTableCustomElement.prototype.columnsChanged = function columnsChanged(newValue) {
      this.restoreVisibleColumns(this.columns);
      this.bindVisibleColumns(this.columns);

      this.restoreFilteredColumns(this.columns);
      this.bindFilteredColumns(this.columns);

      var sortDefCol = this.columns.find(function (x) {
        return x.defaultSort;
      });
      if (sortDefCol) {
        this.sort(sortDefCol);
      }

      if (this.readData) {
        this.getData();
      }
    };

    HandyTableCustomElement.prototype.dataSetChanged = function dataSetChanged(newValue) {
      this.dataList = this.dataSet;
    };

    HandyTableCustomElement.prototype.bindVisibleColumns = function bindVisibleColumns(columns) {
      this.visiblecolumns = columns.filter(function (x) {
        return x.visible;
      });
    };

    HandyTableCustomElement.prototype.bindFilteredColumns = function bindFilteredColumns(columns) {
      this.filteredColumns = columns.filter(function (x) {
        return x.canbefiltered;
      });
    };

    HandyTableCustomElement.prototype.getViewDataDisplay = function getViewDataDisplay(o, column) {
      if (column.getviewdata) return column.getviewdata({ data: o });else return undefined;
    };

    HandyTableCustomElement.prototype.createNewClicked = function createNewClicked($event) {
      if (this.createNewCallback) this.createNewCallback();
    };

    HandyTableCustomElement.prototype.setAllFiltersClicked = function setAllFiltersClicked($event) {
      this.filteredColumns.forEach(function (entry) {
        entry.filterActive = true;
      });

      if (this.readData) {
        this.getData();
      }

      this.storeFilteredColumns(this.columns);

      $event.stopPropagation();
    };

    HandyTableCustomElement.prototype.applyFiltersClicked = function applyFiltersClicked($event) {
      if (this.readData) {
        this.getData();
      }

      this.storeFilteredColumns(this.columns);

      $event.stopPropagation();
    };

    HandyTableCustomElement.prototype.filterOptionClicked = function filterOptionClicked($event) {
      $event.stopPropagation();
      return true;
    };

    HandyTableCustomElement.prototype.clearFiltersClicked = function clearFiltersClicked($event) {
      this.filteredColumns.forEach(function (entry) {
        entry.filterActive = false;
      });

      if (this.readData) {
        this.getData();
      }

      this.storeFilteredColumns(this.columns);

      $event.stopPropagation();
    };

    HandyTableCustomElement.prototype.keyClicked = function keyClicked($o) {
      this.skipRowClick = true;

      $o.$isSelected = !$o.$isSelected;
    };

    HandyTableCustomElement.prototype.rowSelected = function rowSelected($event) {
      if (this.selectedCallback) this.selectedCallback({ data: $event.detail.row });
    };

    HandyTableCustomElement.prototype.rowClicked = function rowClicked($o) {

      try {
        if (!this.skipRowClick) {
          if ($o && $o.$isSelected) {
            if (this.selectedCallback) this.selectedCallback({ data: null });
          }
        }
      } finally {
        this.skipRowClick = false;
      }
    };

    HandyTableCustomElement.prototype.normalizeMimeType = function normalizeMimeType(mimetype, filename) {
      if (mimetype == 'XML' || mimetype == 'xML$') {
        return 'application/xml';
      } else if (mimetype == 'TEXT' || mimetype == 'tEXT$') {
        return 'text/plain';
      } else if (mimetype == 'Binary' || mimetype == 'binary$') {
        if (filename.toLowerCase().endsWith('.zip')) {
          return 'application/zip';
        } else return 'application/octet-stream';
      } else return mimetype;
    };

    HandyTableCustomElement.prototype.converBase64toBlob = function converBase64toBlob(content, contentType) {
      contentType = contentType || '';
      var sliceSize = 512;
      var byteCharacters = window.atob(content);
      var byteArrays = [];
      for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        var slice = byteCharacters.slice(offset, offset + sliceSize);
        var byteNumbers = new Array(slice.length);
        for (var i = 0; i < slice.length; i++) {
          byteNumbers[i] = slice.charCodeAt(i);
        }
        var byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
      }
      var blob = new Blob(byteArrays, {
        type: contentType
      });
      return blob;
    };

    HandyTableCustomElement.prototype.dataContenttoFile = function dataContenttoFile(dataContent, filename, mime) {
      var data = this.converBase64toBlob(dataContent, mime);

      return new File([data], filename, { type: mime });
    };

    HandyTableCustomElement.prototype.hasValue = function hasValue($o, column) {
      var val = column.field ? this.evaluator.evaluateInterpolation('${' + column.field + '}', $o) : undefined;
      return val;
    };

    HandyTableCustomElement.prototype.downloadClicked = function downloadClicked($o, column) {
      var _this3 = this;

      var fileName = 'file.txt';

      if (column.downloadGetDataCallback) {
        column.downloadGetDataCallback({ data: $o }).then(function (fileresp) {
          var file = _this3.dataContenttoFile(fileresp.content, fileresp.filename, _this3.normalizeMimeType(fileresp.mimetype, fileresp.filename));

          fileName = fileresp.filename;
          return URL.createObjectURL(file);
        }).then(function (url) {
          var anchor = document.createElement("a");
          anchor.href = url;
          anchor.setAttribute("download", fileName);
          anchor.innerHTML = "downloading...";
          anchor.style.display = "none";
          document.body.appendChild(anchor);
          setTimeout(function () {
            anchor.click();
            document.body.removeChild(anchor);
            setTimeout(function () {
              self.URL.revokeObjectURL(anchor.href);
            }, 200);
          }, 50);

          return true;
        });
      }
    };

    HandyTableCustomElement.prototype.hasOptionalColumns = function hasOptionalColumns() {
      return this.canHideColumns;
    };

    HandyTableCustomElement.prototype.storeVisibleColumns = function storeVisibleColumns(columns) {
      var cvarray = columns.map(function (x) {
        return { key: x.storeKey, vis: x.visible };
      });
      var visJson = JSON.stringify(cvarray);

      window.localStorage.setItem(this.localStoreKey + this.tabident, visJson);
    };

    HandyTableCustomElement.prototype.restoreVisibleColumns = function restoreVisibleColumns(columns) {
      var visJson = window.localStorage.getItem(this.localStoreKey + this.tabident);
      if (visJson) {
        var cvarray = JSON.parse(visJson);
        if (Array.isArray(cvarray)) {
          cvarray.forEach(function (x) {
            var c = columns.find(function (y) {
              return y.storeKey == x.key;
            });
            if (c) {
              c.visible = x.vis;
            }
          });
        }
      }
    };

    HandyTableCustomElement.prototype.storeFilteredColumns = function storeFilteredColumns(columns) {
      var cvarray = columns.map(function (x) {
        return x.filterToJsonObject();
      });
      console.log('storeFilteredColumns');
      console.log(cvarray);

      var fltJson = JSON.stringify(cvarray);

      window.localStorage.setItem(this.localStoreKey + this.tabident + this.localStoreFilterSubKey, fltJson);
    };

    HandyTableCustomElement.prototype.restoreFilteredColumns = function restoreFilteredColumns(columns) {
      var fltJson = window.localStorage.getItem(this.localStoreKey + this.tabident + this.localStoreFilterSubKey);
      if (fltJson) {
        var cvarray = JSON.parse(fltJson);
        if (Array.isArray(cvarray)) {
          cvarray.forEach(function (x) {
            var c = columns.find(function (y) {
              return y.storeKey == x.key;
            });
            if (c) {
              c.jsonObjectToFilter(x);
            }
          });
        }
      }
    };

    HandyTableCustomElement.prototype.columnVisibilityClicked = function columnVisibilityClicked($event, $o) {
      $o.visible = !$o.visible;

      this.storeVisibleColumns(this.columns);
      this.bindVisibleColumns(this.columns);

      $event.stopPropagation();
    };

    HandyTableCustomElement.prototype.columnFiltersClicked = function columnFiltersClicked($event, $o) {
      $o.filterActive = !$o.filterActive;

      this.storeFilteredColumns(this.columns);
      this.bindFilteredColumns(this.columns);

      if (this.readData) {
        this.getData();
      }

      $event.stopPropagation();
    };

    HandyTableCustomElement.prototype.attached = function attached() {
      var _this4 = this;

      if (this.dataSet) {
        this.dataList = this.dataSet;
      }

      if (this.readData) {
        this.subscriberBlock = this.eventAggregator.subscribe('block', function (o) {
          _this4.getData();
        });
      }

      this.initFilters();
    };

    HandyTableCustomElement.prototype.detached = function detached() {
      if (this.subscriberBlock) this.subscriberBlock.dispose();
    };

    HandyTableCustomElement.prototype.pickerDateTime1Changed = function pickerDateTime1Changed() {};

    HandyTableCustomElement.prototype.pickerDateTime2Changed = function pickerDateTime2Changed() {};

    HandyTableCustomElement.prototype.pickerDateChanged = function pickerDateChanged() {};

    HandyTableCustomElement.prototype.initFilters = function initFilters() {
      $(document).on('click.bs.dropdown.data-api', '.keepopen', function (e) {
        e.stopPropagation();
      });
    };

    return HandyTableCustomElement;
  }(), (_descriptor = _applyDecoratedDescriptor(_class2.prototype, 'tabident', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor2 = _applyDecoratedDescriptor(_class2.prototype, 'columns', [_dec2], {
    enumerable: true,
    initializer: function initializer() {
      return [];
    }
  }), _descriptor3 = _applyDecoratedDescriptor(_class2.prototype, 'canHideColumns', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return true;
    }
  }), _descriptor4 = _applyDecoratedDescriptor(_class2.prototype, 'canFilterColumns', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return true;
    }
  }), _descriptor5 = _applyDecoratedDescriptor(_class2.prototype, 'pageable', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return true;
    }
  }), _descriptor6 = _applyDecoratedDescriptor(_class2.prototype, 'pageSize', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return 20;
    }
  }), _descriptor7 = _applyDecoratedDescriptor(_class2.prototype, 'page', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return 1;
    }
  }), _descriptor8 = _applyDecoratedDescriptor(_class2.prototype, 'pagerSize', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return 20;
    }
  }), _descriptor9 = _applyDecoratedDescriptor(_class2.prototype, 'loadingMessage', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return "Loading data...";
    }
  }), _descriptor10 = _applyDecoratedDescriptor(_class2.prototype, 'loadingDiv', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return "<span>Loading data...</span>";
    }
  }), _descriptor11 = _applyDecoratedDescriptor(_class2.prototype, 'readData', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor12 = _applyDecoratedDescriptor(_class2.prototype, 'dataSet', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor13 = _applyDecoratedDescriptor(_class2.prototype, 'onReadError', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor14 = _applyDecoratedDescriptor(_class2.prototype, 'selectedCallback', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor15 = _applyDecoratedDescriptor(_class2.prototype, 'createNewCallback', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor16 = _applyDecoratedDescriptor(_class2.prototype, 'canCreate', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return function () {
        return true;
      };
    }
  }), _descriptor17 = _applyDecoratedDescriptor(_class2.prototype, 'canDelete', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return function () {
        return true;
      };
    }
  }), _descriptor18 = _applyDecoratedDescriptor(_class2.prototype, 'canCancelFilter', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return function () {
        return true;
      };
    }
  }), _descriptor19 = _applyDecoratedDescriptor(_class2.prototype, 'minHeight', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return '400px';
    }
  }), _descriptor20 = _applyDecoratedDescriptor(_class2.prototype, 'pickerDateTime1', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: null
  }), _descriptor21 = _applyDecoratedDescriptor(_class2.prototype, 'pickerDateTime2', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: null
  })), _class2)) || _class);
});
define('text!resources/elements/handy-table.html', ['module'], function(module) { module.exports = "<template class=\"flex-fill-column\">\n  <require from=\"./key\"></require>\n  <require from=\"./field-value-converters\"></require>\n  <require from=\"./spinner\"></require>\n\n  <!--widget-row-full-->\n\n  <!--<div class=\"input-daterange input-group\" id=\"datepicker1\">-->\n    <!--<input type=\"text\" class=\"input-sm form-control\" name=\"start\" />-->\n    <!--<span class=\"input-group-addon\">to</span>-->\n    <!--<input type=\"text\" class=\"input-sm form-control\" name=\"end\" />-->\n  <!--</div>-->\n\n  <div>\n    <!--<div class=\"aut-pager-container\">-->\n      <!--<template replaceable part=\"caption-part\">-->\n        <!--<div class=\"form-inline\">-->\n          <!--<button class=\"float-none btn btn-success\" if.bind=\"canFilter()\"-->\n                  <!--click.trigger=\"filterNewClicked()\" t=\"filter\">filter</span>-->\n            <!--<i class=\"fa fa-plus-square\"></i>-->\n          <!--</button>-->\n          <!--<button class=\"float-none btn btn-success\" if.bind=\"canCancelFilter()\"-->\n                  <!--click.trigger=\"cancelFilterNewClicked()\" t=\"cancelFilter\">cancelFilter</span>-->\n            <!--<i class=\"fa fa-plus-square\"></i>-->\n          <!--</button>-->\n        <!--</div>-->\n      <!--</template>-->\n    <!--</div>-->\n    <div class=\"aut-pager-container\">\n      <template replaceable part=\"caption-part\">\n        <!--style=\"margin-left: 10px; margin-right: auto;\"-->\n        <div class=\"form-inline\">\n          <button class=\"float-none btn btn-success\" if.bind=\"canCreate()\"\n                  click.trigger=\"createNewClicked()\"><span t=\"create\">create</span>\n            <i class=\"fa fa-plus-square\"></i>\n          </button>\n        </div>\n      </template>\n\n<!--      <aut-pagination current-page.bind=\"currentPage\"-->\n<!--                      page-size.bind=\"pageSize\"-->\n<!--                      total-items.bind=\"totalItems\"-->\n<!--                      pagination-size.bind=\"5\"-->\n<!--                      boundary-links.bind=\"true\"-->\n<!--                      first-text=\"В начало\" last-text=\"В конец\" class=\"form-inline\" style=\"margin-left: auto\">-->\n\n<!--        <template replace-part=\"pagination\">-->\n<!--          <nav class=\"aut-pager-pages\">-->\n<!--            <ul class=\"pagination\" hide.bind=\"hideSinglePage && totalPages === 1\">-->\n<!--              <li class=\"page-item\">-->\n<!--                <a aria-label=\"Previous\" click.delegate=\"previousPage()\"-->\n<!--                   class-name.bind=\"currentPage === 1 ? 'page-link disabled' : 'page-link'\">-->\n<!--                  <span aria-hidden=\"true\">&laquo;</span>-->\n<!--                  <span class=\"sr-only\">Previous</span>-->\n<!--                </a>-->\n<!--              </li>-->\n\n<!--              <li class=\"page-item\" repeat.for=\"page of displayPages\">-->\n<!--                <a click.delegate=\"selectPage(page.value)\"-->\n<!--                   class-name.bind=\"currentPage === page.value ? 'page-link active btn-light' : 'page-link btn-light'\">-->\n<!--                  ${page.title}-->\n<!--                </a>-->\n<!--              </li>-->\n\n<!--              <li class=\"page-item\">-->\n<!--                <a aria-label=\"Next\" click.delegate=\"nextPage()\"-->\n<!--                   class-name.bind=\"currentPage === totalPages ? 'page-link disabled' : 'page-link'\">-->\n<!--                  <span aria-hidden=\"true\">&raquo;</span>-->\n<!--                  <span class=\"sr-only\">Next</span>-->\n<!--                </a>-->\n<!--              </li>-->\n<!--            </ul>-->\n<!--          </nav>-->\n<!--        </template>-->\n\n<!--      </aut-pagination>-->\n\n      <div class=\"form-inline\" style=\"margin-left: auto; margin-right: 0px;\">\n\n<!--        <div class=\"form-group pull-right\">-->\n<!--          <label for=\"pageSize\" t=\"pageSize\">:</label>-->\n<!--          <select value.bind=\"pageSize\" id=\"pageSize\" class=\"form-control\">-->\n<!--            <option model.bind=\"2\">2</option>-->\n<!--            <option model.bind=\"5\">5</option>-->\n<!--            <option model.bind=\"10\">10</option>-->\n<!--            <option model.bind=\"20\">20</option>-->\n<!--            <option model.bind=\"50\">50</option>-->\n<!--          </select>-->\n<!--        </div>-->\n\n        <div class=\"btn-group\" style=\"margin-left: 5px;\" if.bind=\"canFilterColumns\">\n          <button type=\"button\" class=\"float-right btn btn-default dropdown-toggle\" data-toggle=\"dropdown\"><span\n            t=\"columnFilters\">columnFilters</span><span class=\"caret\"></span>\n            <i class=\"fa fa-filter\"></i>\n          </button>\n\n          <!--scrolled-menu-->\n          <ul class=\"dropdown-menu  keepopen\" style=\"min-width: 800px;\">\n            <div class.bind=\"'inline-cont '\">\n              <div class=\"btn-group\" role=\"group\">\n                <button type=\"button\" class=\"btn btn-secondary\" click.trigger=\"clearFiltersClicked($event)\" >\n                  <span\n                    t=\"clearFilters\">clearFilters</span><span class=\"caret\"></span>\n                  <i class=\"fa fa-minus-square\"></i>\n                </button>\n                <button type=\"button\" class=\"btn btn-secondary\" click.trigger=\"setAllFiltersClicked($event)\">\n                  <span\n                    t=\"setAllFilters\">setAllFilters</span><span class=\"caret\"></span>\n                  <i class=\"fa fa-check-square\"></i>\n                </button>\n\n                <button type=\"button\" class=\"btn btn-secondary\" click.trigger=\"applyFiltersClicked($event)\">\n                  <span\n                    t=\"applyFilters\">applyFilters</span><span class=\"caret\"></span>\n                  <i class=\"fa fa-retweet\"></i>\n                </button>\n              </div>\n            </div>\n            <li repeat.for=\"$o of filteredColumns\" class.bind=\"'inline-cont ' + ($o.filterActive ? 'widget-selected' : '')\">\n\n                <div class=\"inline-cont inline-cont-item dropdown-menu-item checkbox custom-control custom-checkbox\" click.trigger=\"columnFiltersClicked($event, $o)\"\n                     style=\"max-width: 350px;\">\n                  <input type=\"checkbox\" class=\"inline-cont-item custom-control-input\" id.bind=\"'option-' + $index\"\n                         checked.bind=\"$o.filterActive\"/>\n                  <label class=\"inline-cont-item custom-control-label\" for.bind=\"'option-' + $index\" t.bind=\"$o.resourcekey\">Col\n                    name</label>\n                </div>\n\n                <template if.bind=\"$o.viewtype == 'date'\" containerless>\n                  <div class=\"inline-cont-item inline-cont\" >\n                    <abp-datetime-picker class=\"inline-cont-item\" element.bind=\"pickerDate1\" icon-base=\"font-awesome\" with-date-icon=\"true\" options.bind=\"{ format: 'YYYY-MM-DD', locale: 'ru' }\" model.bind=\"$o.filterValue.from\"></abp-datetime-picker>\n                    <span style=\"margin: 3px;\">до</span>\n                    <abp-datetime-picker class=\"inline-cont-item\" element.bind=\"pickerDate2\" icon-base=\"font-awesome\" with-date-icon=\"true\" options.bind=\"{ format: 'YYYY-MM-DD', locale: 'ru' }\" model.bind=\"$o.filterValue.to\"></abp-datetime-picker>\n                  </div>\n                </template>\n\n              <template if.bind=\"$o.viewtype == 'datetime'\" containerless>\n                <div class=\"inline-cont-item inline-cont\" >\n                  <abp-datetime-picker class=\"inline-cont-item\" element.bind=\"pickerDateTime1\" icon-base=\"font-awesome\" with-date-icon=\"true\" options.bind=\"{ format: 'YYYY-MM-DD HH:mm', sideBySide: true, showClose: true, locale: 'ru' }\" model.bind=\"$o.filterValue.from\"></abp-datetime-picker>\n                  <span style=\"margin: 3px;\">до</span>\n                  <abp-datetime-picker class=\"inline-cont-item\" element.bind=\"pickerDateTime2\" icon-base=\"font-awesome\" with-date-icon=\"true\" options.bind=\"{ format: 'YYYY-MM-DD HH:mm', sideBySide: true, showClose: true, locale: 'ru' }\" model.bind=\"$o.filterValue.to\"></abp-datetime-picker>\n                </div>\n              </template>\n\n              <!--value.bind=\"accountEdit.value.comment\"-->\n              <!--<option repeat.for=\"fo of $o.filterOptions\" model.bind=\"fo.id\" onclick.trigger=\"filterOptionClicked($event)\">-->\n              <template if.bind=\"$o.viewtype == 'text'\" containerless>\n                <div class=\"inline-cont-item2 inline-cont\" >\n                  <input if.bind=\"!$o.filterOptions\" type=\"text\" class=\"inline-cont-item2 form-control\" value.bind=\"$o.filterValue\">\n                  <select if.bind=\"$o.filterOptions\" class=\"form-control\" onblur.trigger=\"filterOptionClicked($event)\"\n                          value.bind=\"$o.filterValue\">\n                    <option repeat.for=\"fo of $o.filterOptions\" value=\"${fo | fieldValueDisplay:$o.filterOptionKey:$o.format:$o.viewtype}\" onclick.trigger=\"filterOptionClicked($event)\">\n                      ${fo | fieldValueDisplay:$o.filterOptionField:$o.format:$o.viewtype}\n                    </option>\n\n                    <!--<option repeat.for=\"fo of $o.filterOptions\" model.bind=\"fo.id\" onclick.trigger=\"filterOptionClicked($event)\">${fo.id} - ${fo.value.name}</option>-->\n                  </select>\n\n                </div>\n              </template>\n\n              <template if.bind=\"$o.viewtype == 'key'\" containerless>\n                <div class=\"inline-cont-item2 inline-cont\" >\n                  <input type=\"text\" class=\"inline-cont-item2 form-control\" value.bind=\"$o.filterValue\">\n                </div>\n              </template>\n\n              <template if.bind=\"$o.viewtype == 'download'\" containerless>\n                <div class=\"inline-cont-item2 inline-cont\" >\n                  <input type=\"text\" class=\"inline-cont-item2 form-control\" value.bind=\"$o.filterValue\">\n                </div>\n              </template>\n\n\n            </li>\n          </ul>\n        </div>\n\n        <div class=\"btn-group\" style=\"margin-left: 5px;\" if.bind=\"canHideColumns\">\n          <button type=\"button\" class=\"float-right btn btn-default dropdown-toggle\" data-toggle=\"dropdown\"><span\n            t=\"columnvisibility\">columnvisibility</span><span class=\"caret\"></span>\n            <i class=\"fa fa-eye-slash\"></i>\n          </button>\n\n          <ul class=\"dropdown-menu scrolled-menu\">\n            <li repeat.for=\"$o of columns\" class.bind=\"'' + ($o.visible ? 'widget-selected' : '')\"\n                click.trigger=\"columnVisibilityClicked($event, $o)\">\n              <div class=\"dropdown-menu-item checkbox custom-control custom-checkbox\">\n                <input type=\"checkbox\" class=\"custom-control-input\" id.bind=\"'option-' + $index\"\n                       checked.bind=\"$o.visible\"/>\n                <label class=\"custom-control-label\" for.bind=\"'option-' + $index\" t.bind=\"$o.resourcekey\">Col\n                  name</label>\n              </div>\n            </li>\n          </ul>\n        </div>\n\n      </div>\n\n\n    </div>\n  </div>\n\n  <div class=\"table-responsive\" style=\"flex: 1;\">\n    <spinner busy.bind=\"loading\" mode=\"'context'\"></spinner>\n    <div class=\"aut-table-container\">\n      <table class=\"table table-striped table-condensed table-bordered\"\n             aurelia-table=\"data.bind: dataList; display-data.bind: $listDisplayData; current-page.bind: currentPage; page-size.bind: pageSize; total-items.bind: totalItems;\">\n\n        <!--text-transform: uppercase;-->\n        <caption style=\"caption-side: top; text-align: left; padding-top: .2rem; padding-bottom: .2rem;\">\n          <!--row aut-pager-container-->\n          <!--<div class=\"aut-pager-container\">-->\n          <!--<template replaceable part=\"caption-part\">-->\n          <!--&lt;!&ndash;style=\"margin-left: 10px; margin-right: auto;\"&ndash;&gt;-->\n          <!--<div class=\"form-inline\">-->\n          <!--<button class=\"float-none btn btn-success\" if.bind=\"canCreate()\"-->\n          <!--click.trigger=\"createNewClicked()\"><span t=\"create\">create</span>-->\n          <!--<i class=\"fa fa-plus-square\"></i>-->\n          <!--</button>-->\n          <!--</div>-->\n          <!--</template>-->\n\n          <!--<aut-pagination current-page.bind=\"currentPage\" page-size.bind=\"pageSize\" total-items.bind=\"totalItems\"-->\n          <!--pagination-size.bind=\"5\" boundary-links.bind=\"true\" first-text=\"В начало\" last-text=\"В конец\" class=\"form-inline\" style=\"margin-left: auto\">-->\n\n          <!--<template replace-part=\"pagination\">-->\n          <!--<nav class=\"aut-pager-pages\">-->\n          <!--<ul class=\"pagination\" hide.bind=\"hideSinglePage && totalPages === 1\">-->\n          <!--<li class=\"page-item\">-->\n          <!--<a aria-label=\"Previous\" click.delegate=\"previousPage()\"-->\n          <!--class-name.bind=\"currentPage === 1 ? 'page-link disabled' : 'page-link'\">-->\n          <!--<span aria-hidden=\"true\">&laquo;</span>-->\n          <!--<span class=\"sr-only\">Previous</span>-->\n          <!--</a>-->\n          <!--</li>-->\n\n          <!--<li class=\"page-item\" repeat.for=\"page of displayPages\">-->\n          <!--<a click.delegate=\"selectPage(page.value)\"-->\n          <!--class-name.bind=\"currentPage === page.value ? 'page-link active btn-light' : 'page-link btn-light'\">-->\n          <!--${page.title}-->\n          <!--</a>-->\n          <!--</li>-->\n\n          <!--<li class=\"page-item\">-->\n          <!--<a aria-label=\"Next\" click.delegate=\"nextPage()\"-->\n          <!--class-name.bind=\"currentPage === totalPages ? 'page-link disabled' : 'page-link'\">-->\n          <!--<span aria-hidden=\"true\">&raquo;</span>-->\n          <!--<span class=\"sr-only\">Next</span>-->\n          <!--</a>-->\n          <!--</li>-->\n          <!--</ul>-->\n          <!--</nav>-->\n          <!--</template>-->\n\n          <!--</aut-pagination>-->\n\n          <!--<div class=\"form-inline\" style=\"margin-left: auto; margin-right: 0px;\">-->\n\n          <!--<div class=\"form-group pull-right\">-->\n          <!--<label for=\"pageSize\" t=\"pageSize\">:</label>-->\n          <!--<select value.bind=\"pageSize\" id=\"pageSize\" class=\"form-control\">-->\n          <!--<option model.bind=\"2\">2</option>-->\n          <!--<option model.bind=\"5\">5</option>-->\n          <!--<option model.bind=\"10\">10</option>-->\n          <!--<option model.bind=\"20\">20</option>-->\n          <!--<option model.bind=\"50\">50</option>-->\n          <!--</select>-->\n          <!--</div>-->\n\n          <!--<div class=\"btn-group\" style=\"margin-left: 5px;\" if.bind=\"canHideColumns\">-->\n          <!--<button type=\"button\" class=\"float-right btn btn-default dropdown-toggle\" data-toggle=\"dropdown\"><span t=\"columnvisibility\">columnvisibility</span><span class=\"caret\"></span>-->\n          <!--<i class=\"fa fa-eye-slash\"></i>-->\n          <!--</button>-->\n\n          <!--<ul class=\"dropdown-menu scrolled-menu\">-->\n          <!--<li repeat.for=\"$o of columns\" class.bind=\"'' + ($o.visible ? 'widget-selected' : '')\" click.trigger=\"columnVisibilityClicked($event, $o)\" >-->\n          <!--<div class=\"dropdown-menu-item checkbox custom-control custom-checkbox\">-->\n          <!--<input type=\"checkbox\" class=\"custom-control-input\" id.bind=\"'option-' + $index\" checked.bind=\"$o.visible\" />-->\n          <!--<label class=\"custom-control-label\" for.bind=\"'option-' + $index\" t.bind=\"$o.resourcekey\">Col name</label>-->\n          <!--</div>-->\n          <!--</li>-->\n          <!--</ul>-->\n          <!--</div>-->\n\n          <!--</div>-->\n\n\n          <!--</div>-->\n\n\n        </caption>\n\n\n        <thead class=\"aut-table-head\">\n\n\n        <!--aut-sort=\"key.bind: $column.sortable ? ($column.field ? $column.field : getViewDataDisplay$column.getviewdata) : undefined; \"-->\n        <!--aut-sort=\"custom.bind: columnSort\"-->\n        <!--aut-sort=\"key.bind: $column.sortable ? ($column.field ? $column.field : $column.sortTextView) : undefined; \"-->\n        <!--aut-sort=\"key.bind: columnSortableText ($column)\"-->\n        <!--click.capture=\"sort($index, $column)\"-->\n        <!--default.bind: $column.field-->\n\n        <!--filtered.bind=\"$column.filterActive ? 'filtered' : ''\"-->\n        <tr role=\"button\">\n          <th repeat.for=\"$column of visiblecolumns\" click.capture=\"sort($column)\"\n              aut-sort=\"custom.bind: $column.sortable ? sortColumnData : undefined; default.bind: $column.defaultSort ? $column.defaultSort : undefined; \"\n              data-filtered.bind=\"$column.filterActive ? 'filtered' : ''\"\n              t.bind=\"$column.resourcekey\">\n          </th>\n        </tr>\n\n        </thead>\n\n        <tbody class=\"aut-table-body\">\n        <tr repeat.for=\"o of $listDisplayData\" aut-select=\"row.bind: o; mode: single; selected-class: aut-row-handy-sel\"\n            select.delegate=\"rowSelected($event)\" click.trigger=\"rowClicked(o)\">\n\n          <td repeat.for=\"$column of visiblecolumns\" as-element=\"compose\">\n            <button if.bind=\"$column.viewtype == 'key'\" class=\"btn btn-link\" click.trigger=\"keyClicked(o)\">\n              <key data.bind=\"o.key\"></key>\n            </button>\n\n            <template if.bind=\"$column.viewtype == 'download'\" containerless>\n              <div if.bind=\"hasValue(o, $column)\" containerless>\n                <a if.bind=\"$column.downloadGetDataCallback\" href=\"#\">\n                <span if.bind=\"$column.field\" click.trigger=\"downloadClicked(o, $column)\">\n                  ${o | fieldValueDisplay:$column.field:$column.format}\n                </span>\n                </a>\n\n                <span if.bind=\"!$column.downloadGetDataCallback && $column.field\" click.trigger=\"keyClicked(o)\">\n                ${o | fieldValueDisplay:$column.field:$column.format}\n              </span>\n              </div>\n              <div else click.trigger=\"keyClicked(o)\" containerless>\n                <b>--</b>\n              </div>\n            </template>\n\n\n            <span if.bind=\"$column.viewtype == 'text' && $column.field\" click.trigger=\"keyClicked(o)\">\n            ${o | fieldValueDisplay:$column.field:$column.format}\n          </span>\n\n            <span if.bind=\"$column.viewtype == 'text' && !$column.field\" containerless click.trigger=\"keyClicked(o)\">\n            ${getViewDataDisplay(o, $column)}\n          </span>\n\n            <template if.bind=\"$column.viewtype == 'datetime'\" containerless>\n            <span if.bind=\"$column.field\" containerless click.trigger=\"keyClicked(o)\">\n              ${o | fieldValueDisplay:$column.field:$column.format:$column.viewtype}\n            </span>\n            </template>\n\n            <template if.bind=\"$column.viewtype == 'date'\" containerless>\n            <span if.bind=\"$column.field\" containerless click.trigger=\"keyClicked(o)\">\n              ${o | fieldValueDisplay:$column.field:$column.format:$column.viewtype}\n            </span>\n            </template>\n\n            <!--<compose view=\"./widgets/table-view-${column.viewtype}.html\" containerless model.bind=\"widget.data\"></compose>-->\n          </td>\n\n        </tr>\n        </tbody>\n      </table>\n    </div>\n\n  </div>\n\n  <slot></slot>\n</template>\n"; });
define('text!resources/elements/handy-table-td.html', ['module'], function(module) { module.exports = "<template bindable=\"\">\n\n</template>\n"; });
define('resources/elements/footer-alerts',['exports', 'aurelia-framework', './../../services/alert-service', 'moment'], function (exports, _aureliaFramework, _alertService, _moment) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.FooterAlertsCustomElement = undefined;

  var _moment2 = _interopRequireDefault(_moment);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      default: obj
    };
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _createClass = function () {
    function defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }

    return function (Constructor, protoProps, staticProps) {
      if (protoProps) defineProperties(Constructor.prototype, protoProps);
      if (staticProps) defineProperties(Constructor, staticProps);
      return Constructor;
    };
  }();

  function _applyDecoratedDescriptor(target, property, decorators, descriptor, context) {
    var desc = {};
    Object['ke' + 'ys'](descriptor).forEach(function (key) {
      desc[key] = descriptor[key];
    });
    desc.enumerable = !!desc.enumerable;
    desc.configurable = !!desc.configurable;

    if ('value' in desc || desc.initializer) {
      desc.writable = true;
    }

    desc = decorators.slice().reverse().reduce(function (desc, decorator) {
      return decorator(target, property, desc) || desc;
    }, desc);

    if (context && desc.initializer !== void 0) {
      desc.value = desc.initializer ? desc.initializer.call(context) : void 0;
      desc.initializer = undefined;
    }

    if (desc.initializer === void 0) {
      Object['define' + 'Property'](target, property, desc);
      desc = null;
    }

    return desc;
  }

  var _dec, _dec2, _dec3, _dec4, _dec5, _class, _desc, _value, _class2, _class3, _temp;

  var FooterAlertsCustomElement = exports.FooterAlertsCustomElement = (_dec = (0, _aureliaFramework.inject)(_alertService.AlertService, _aureliaFramework.BindingEngine), _dec2 = (0, _aureliaFramework.computedFrom)('alertService._alertMessages.length'), _dec3 = (0, _aureliaFramework.computedFrom)('alertService._alertMessages.length', 'staticMessagesAcknCount', 'alertStackViewState'), _dec4 = (0, _aureliaFramework.computedFrom)('alertService._alertMessages.length'), _dec5 = (0, _aureliaFramework.computedFrom)('alertStackViewState'), _dec(_class = (_class2 = (_temp = _class3 = function () {
    function FooterAlertsCustomElement(alertService, bindingEngine) {
      _classCallCheck(this, FooterAlertsCustomElement);

      this.alertStackViewState = 'closed';
      this.topAlertState = 'passiv';

      this.alertService = alertService;
      this.bindingEngine = bindingEngine;
    }

    FooterAlertsCustomElement.prototype.attached = function attached() {
      this.observeData();
    };

    FooterAlertsCustomElement.prototype.observeData = function observeData() {
      var _this = this;

      if (this.subscription) {
        this.subscription.dispose();
      }
      this.subscription = this.bindingEngine.expressionObserver(this, 'alertService._alertMessages.length').subscribe(function (newValue, oldValue) {
        _this.dataChanged(newValue, oldValue);
      });
    };

    FooterAlertsCustomElement.prototype.detached = function detached() {
      if (this.subscription) {
        this.subscription.dispose();
      }
    };

    FooterAlertsCustomElement.prototype.dataChanged = function dataChanged(newValue, oldValue) {
      var _this2 = this;

      if (newValue != oldValue) {
        this.topAlertState = 'passiv';
        this.topAlertState = 'transit';

        setTimeout(function () {
          _this2.topAlertState = 'passiv';
        }, 5000);
      }
    };

    FooterAlertsCustomElement.prototype.toggleAlertStackPanel = function toggleAlertStackPanel() {
      if (this.alertStackViewState == 'closed') {

        this.alertStackViewState = 'opened';
        FooterAlertsCustomElement.messagesAcknCount = this.alertService._alertMessages.length;
      } else if (this.alertStackViewState == 'opened') {

        this.alertStackViewState = 'closed';
        FooterAlertsCustomElement.messagesAcknCount = this.alertService._alertMessages.length;
      }
    };

    _createClass(FooterAlertsCustomElement, [{
      key: 'alertMessages',
      get: function get() {
        return this.alertService._alertMessages;
      }
    }, {
      key: 'notReadMessagesCount',
      get: function get() {
        if (this.alertStackViewState == 'opened') {
          return 0;
        }

        return this.alertService._alertMessages.length >= FooterAlertsCustomElement.messagesAcknCount ? this.alertService._alertMessages.length - FooterAlertsCustomElement.messagesAcknCount : this.alertService._alertMessages.length;
      }
    }, {
      key: 'staticMessagesAcknCount',
      get: function get() {
        return FooterAlertsCustomElement.messagesAcknCount;
      }
    }, {
      key: 'topMessage',
      get: function get() {
        return this.alertService._alertMessages[0];
      }
    }, {
      key: 'alertPanelClass',
      get: function get() {
        if (this.alertStackViewState == 'closed') return "notifications-scroll-area d-none";else if (this.alertStackViewState == 'opened') return "notifications-scroll-area";else return "hidden";
      }
    }]);

    return FooterAlertsCustomElement;
  }(), _class3.messagesAcknCount = 0, _temp), (_applyDecoratedDescriptor(_class2.prototype, 'alertMessages', [_dec2], Object.getOwnPropertyDescriptor(_class2.prototype, 'alertMessages'), _class2.prototype), _applyDecoratedDescriptor(_class2.prototype, 'notReadMessagesCount', [_dec3], Object.getOwnPropertyDescriptor(_class2.prototype, 'notReadMessagesCount'), _class2.prototype), _applyDecoratedDescriptor(_class2.prototype, 'topMessage', [_dec4], Object.getOwnPropertyDescriptor(_class2.prototype, 'topMessage'), _class2.prototype), _applyDecoratedDescriptor(_class2.prototype, 'alertPanelClass', [_dec5], Object.getOwnPropertyDescriptor(_class2.prototype, 'alertPanelClass'), _class2.prototype)), _class2)) || _class);
});
define('text!resources/elements/footer-alerts.html', ['module'], function(module) { module.exports = "<template>\n  <require from=\"./field-value-converters\"></require>\n\n  <footer class=\"page-footer ${alertStackViewState}\" style=\"position: relative; display: flex; \">\n\n    <div class=\"notifications-hdr\" if.bind=\"alertMessages.length == 0\">\n      <div class=\"alert-status alert-status-info alert-passiv\">\n        [<span t=\"alertStackEmptyTitle\">No messages</span>]\n      </div>\n    </div>\n\n      <div class=\"notifications-hdr\" if.bind=\"alertMessages.length > 0\" >\n        <!--<div class=\"alert-block-btn ${('alert-status alert-' + topAlertState + ' alert-status-' + topMessage.type)}\" title=\"${alertMessages.length > 0 ? ('[' + alertMessages[0].title + '] ' + alertMessages[0].message) : 'Нет собщений' }\" click.delegate=\"toggleAlertStackPanel()\">-->\n            <!--<span>${alertMessages.length > 0 ? (alertMessages[0].message) : 'Нет собщений' }</span>-->\n        <!--</div>-->\n\n        <div class=\"hdr-block-right\">\n\n          <div class=\"hdr-block-btn\" click.delegate=\"toggleAlertStackPanel()\">\n            <!--<span t=\"alertStackHistory\">alertStackHistory</span>-->\n            <div class=\"alert-block-btn ${('alert-status alert-' + topAlertState + ' alert-status-' + topMessage.type)}\" title=\"${alertMessages.length > 0 ? ('[' + alertMessages[0].title + '] ' + alertMessages[0].message) : 'Нет собщений' }\" >\n              <span>${alertMessages.length > 0 ? (alertMessages[0].message) : 'Нет собщений' }</span>\n            </div>\n\n            <i class=\"fa fa-list\" style=\"padding-left: 5px;\"></i>\n          </div>\n\n        </div>\n      </div>\n\n        <div id=\"alertStackPanel\" class=\"${alertPanelClass}\" if.bind=\"alertMessages.length > 0\" >\n          <div class=\"notifications-stack\">\n            <div>\n              <div repeat.for=\"$msg of alertMessages\" class=\"notification-it ${$msg.type}\">\n                <span style=\"width: 20em;\">${$msg.time | dateFormat}</span>\n                <span style=\"width: 10em; text-transform: uppercase;\">${$msg.title }</span>\n                <span >${$msg.message}</span>\n              </div>\n            </div>\n\n          </div>\n        </div>\n\n  </footer>\n\n</template>\n"; });
define('resources/elements/field-value-converters',['exports', 'aurelia-framework', './expression-evaluator', 'moment'], function (exports, _aureliaFramework, _expressionEvaluator, _moment) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.DateFormatValueConverter = exports.FieldValueDisplayValueConverter = undefined;

  var _moment2 = _interopRequireDefault(_moment);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      default: obj
    };
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _dec, _class;

  var FieldValueDisplayValueConverter = exports.FieldValueDisplayValueConverter = (_dec = (0, _aureliaFramework.inject)(_expressionEvaluator.ExpressionEvaluator), _dec(_class = function () {
    function FieldValueDisplayValueConverter(evaluator) {
      _classCallCheck(this, FieldValueDisplayValueConverter);

      this.evaluator = evaluator;
    }

    FieldValueDisplayValueConverter.prototype.toView = function toView(value, fieldlocator, format, typenarrow) {
      var fl = fieldlocator;
      if (fieldlocator && fieldlocator.indexOf("_{") >= 0) {
        fl = fieldlocator.replace(new RegExp('_{', 'g'), '${');
      } else {
        fl = fieldlocator ? '${' + fieldlocator + '}' : undefined;
      }

      var message = fl ? this.evaluator.evaluateInterpolation(fl, value) : undefined;


      if (typenarrow && message) {
        if (typenarrow === 'datetime') {

          if (format) {
            message = (0, _moment2.default)(message).format(format);
          }
        }
      }

      if (!message || typeof message == 'string' && message.length <= 0) {
        message = '--';
      }

      return message;
    };

    return FieldValueDisplayValueConverter;
  }()) || _class);

  var DateFormatValueConverter = exports.DateFormatValueConverter = function () {
    function DateFormatValueConverter() {
      _classCallCheck(this, DateFormatValueConverter);
    }

    DateFormatValueConverter.prototype.toView = function toView(value) {
      return (0, _moment2.default)(value).format('DD/MM/YYYY HH:mm:ss');
    };

    return DateFormatValueConverter;
  }();
});
define('resources/elements/expression-evaluator',['exports', 'aurelia-dependency-injection', 'aurelia-templating', 'aurelia-binding'], function (exports, _aureliaDependencyInjection, _aureliaTemplating, _aureliaBinding) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.ExpressionEvaluator = exports.InterpolationParser = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _dec, _class, _dec2, _class3;

  var InterpolationParser = exports.InterpolationParser = (_dec = (0, _aureliaDependencyInjection.inject)(_aureliaBinding.Parser, _aureliaTemplating.BindingLanguage), _dec(_class = function () {
    function InterpolationParser(parser, bindingLanguage) {
      _classCallCheck(this, InterpolationParser);

      this.emptyStringExpression = new _aureliaBinding.LiteralString('');
      this.nullExpression = new _aureliaBinding.LiteralPrimitive(null);
      this.undefinedExpression = new _aureliaBinding.LiteralPrimitive(undefined);
      this.cache = {};

      this.parser = parser;
      this.bindingLanguage = bindingLanguage;
    }

    InterpolationParser.prototype.parse = function parse(expressionText) {
      if (this.cache[expressionText] !== undefined) {
        return this.cache[expressionText];
      }

      var parts = this.bindingLanguage.parseInterpolation(null, expressionText);
      if (parts === null) {
        return new _aureliaBinding.LiteralString(expressionText);
      }
      var expression = new _aureliaBinding.LiteralString(parts[0]);
      for (var i = 1; i < parts.length; i += 2) {
        expression = new _aureliaBinding.Binary('+', expression, new _aureliaBinding.Binary('+', this.coalesce(parts[i]), new _aureliaBinding.LiteralString(parts[i + 1])));
      }

      this.cache[expressionText] = expression;

      return expression;
    };

    InterpolationParser.prototype.coalesce = function coalesce(part) {
      return new _aureliaBinding.Conditional(new _aureliaBinding.Binary('||', new _aureliaBinding.Binary('===', part, this.nullExpression), new _aureliaBinding.Binary('===', part, this.undefinedExpression)), this.emptyStringExpression, new _aureliaBinding.CallMember(part, 'toString', []));
    };

    return InterpolationParser;
  }()) || _class);
  var ExpressionEvaluator = exports.ExpressionEvaluator = (_dec2 = (0, _aureliaDependencyInjection.inject)(_aureliaBinding.Parser, InterpolationParser, _aureliaTemplating.ViewResources), _dec2(_class3 = function () {
    function ExpressionEvaluator(parser, interpolationParser, resources) {
      _classCallCheck(this, ExpressionEvaluator);

      this.parser = parser;
      this.interpolationParser = interpolationParser;
      this.lookupFunctions = resources.lookupFunctions;
    }

    ExpressionEvaluator.prototype.evaluate = function evaluate(expressionText, bindingContext) {
      var expression = this.parser.parse(expressionText);
      return this.evaluateInternal(expression, bindingContext);
    };

    ExpressionEvaluator.prototype.evaluateInterpolation = function evaluateInterpolation(expressionText, bindingContext) {
      var expression = this.interpolationParser.parse(expressionText);
      return this.evaluateInternal(expression, bindingContext);
    };

    ExpressionEvaluator.prototype.evaluateInternal = function evaluateInternal(expression, bindingContext) {
      var scope = {
        bindingContext: bindingContext,
        overrideContext: (0, _aureliaBinding.createOverrideContext)(bindingContext)
      };
      return expression.evaluate(scope, this.lookupFunctions);
    };

    return ExpressionEvaluator;
  }()) || _class3);
});
define('resources/elements/column',['exports', 'aurelia-framework'], function (exports, _aureliaFramework) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.Column = undefined;

  function _initDefineProp(target, property, descriptor, context) {
    if (!descriptor) return;
    Object.defineProperty(target, property, {
      enumerable: descriptor.enumerable,
      configurable: descriptor.configurable,
      writable: descriptor.writable,
      value: descriptor.initializer ? descriptor.initializer.call(context) : void 0
    });
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _createClass = function () {
    function defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }

    return function (Constructor, protoProps, staticProps) {
      if (protoProps) defineProperties(Constructor.prototype, protoProps);
      if (staticProps) defineProperties(Constructor, staticProps);
      return Constructor;
    };
  }();

  function _applyDecoratedDescriptor(target, property, decorators, descriptor, context) {
    var desc = {};
    Object['ke' + 'ys'](descriptor).forEach(function (key) {
      desc[key] = descriptor[key];
    });
    desc.enumerable = !!desc.enumerable;
    desc.configurable = !!desc.configurable;

    if ('value' in desc || desc.initializer) {
      desc.writable = true;
    }

    desc = decorators.slice().reverse().reduce(function (desc, decorator) {
      return decorator(target, property, desc) || desc;
    }, desc);

    if (context && desc.initializer !== void 0) {
      desc.value = desc.initializer ? desc.initializer.call(context) : void 0;
      desc.initializer = undefined;
    }

    if (desc.initializer === void 0) {
      Object['define' + 'Property'](target, property, desc);
      desc = null;
    }

    return desc;
  }

  function _initializerWarningHelper(descriptor, context) {
    throw new Error('Decorating class property failed. Please ensure that transform-class-properties is enabled.');
  }

  var _class, _desc, _value, _class2, _descriptor, _descriptor2, _descriptor3, _descriptor4, _descriptor5, _descriptor6, _descriptor7, _descriptor8, _descriptor9, _descriptor10, _descriptor11, _descriptor12, _descriptor13, _descriptor14, _descriptor15, _descriptor16, _descriptor17;

  var Column = exports.Column = (0, _aureliaFramework.noView)(_class = (_class2 = function () {
    function Column() {
      _classCallCheck(this, Column);

      _initDefineProp(this, 'viewtype', _descriptor, this);

      _initDefineProp(this, 'class', _descriptor2, this);

      _initDefineProp(this, 'resourcekey', _descriptor3, this);

      _initDefineProp(this, 'field', _descriptor4, this);

      _initDefineProp(this, 'format', _descriptor5, this);

      _initDefineProp(this, 'sortable', _descriptor6, this);

      _initDefineProp(this, 'defaultSort', _descriptor7, this);

      _initDefineProp(this, 'canbefiltered', _descriptor8, this);

      _initDefineProp(this, 'filterField', _descriptor9, this);

      _initDefineProp(this, 'downloadGetDataCallback', _descriptor10, this);

      _initDefineProp(this, 'getviewdata', _descriptor11, this);

      _initDefineProp(this, 'visible', _descriptor12, this);

      _initDefineProp(this, 'filterOptions', _descriptor13, this);

      _initDefineProp(this, 'filterOptionField', _descriptor14, this);

      _initDefineProp(this, 'filterOptionKey', _descriptor15, this);

      _initDefineProp(this, 'filterExpressionBuilder', _descriptor16, this);

      _initDefineProp(this, 'filterActive', _descriptor17, this);

      this.filterValue = undefined;
    }

    Column.prototype.sortTextView = function sortTextView(row) {
      if (this.getviewdata) {
        return this.getviewdata(row);
      }
    };

    Column.prototype.filterValueChanged = function filterValueChanged(newValue) {
      console.log('------------------------------filterValueChanged------------------------------');
      console.log(newValue);
    };

    Column.prototype.filterToJsonObject = function filterToJsonObject() {
      var fv = {
        key: this.storeKey,
        act: this.filterActive
      };

      if (this.viewtype == 'text' || this.viewtype == 'key') fv.fval = this.filterValue;else if (this.viewtype == 'download') fv.fval = this.filterValue;else if (this.viewtype == 'date' || this.viewtype == 'datetime') fv.fval = {
        from: this.filterValue && this.filterValue.from ? this.filterValue.from.getTime() : null,
        to: this.filterValue && this.filterValue.to ? this.filterValue.to.getTime() : null
      };

      return fv;
    };

    Column.prototype.jsonObjectToFilter = function jsonObjectToFilter(json) {
      this.filterActive = json.act;
      if (this.viewtype == 'text' || this.viewtype == 'key') this.filterValue = json.fval;else if (this.viewtype == 'download') this.filterValue = json.fval;else if (this.viewtype == 'date' || this.viewtype == 'datetime') if (json.fval) {
        this.filterValue = {};
        this.filterValue.from = json.fval.from ? new Date(json.fval.from) : undefined;
        this.filterValue.to = json.fval.to ? new Date(json.fval.to) : undefined;
      } else this.filterValue = null;
    };

    _createClass(Column, [{
      key: 'filterExpression',
      get: function get() {
        var expr = undefined;

        if (this.filterExpressionBuilder) return this.filterExpressionBuilder({ data: this.filterValue });

        if (this.viewtype == 'text' || this.viewtype == 'key') expr = [{
          type: "eq",
          path: this.filterField ? this.filterField : this.field,
          value: this.filterValue
        }];else if (this.viewtype == 'download') expr = [{
          type: "eq",
          path: this.filterField ? this.filterField : this.field,
          value: this.filterValue
        }];else if (this.viewtype == 'date' || this.viewtype == 'datetime') expr = [{
          type: "gt",
          path: this.filterField ? this.filterField : this.field,
          value: this.filterValue && this.filterValue.from ? this.filterValue.from.getTime() : undefined
        }, {
          type: "lt",
          path: this.filterField ? this.filterField : this.field,
          value: this.filterValue && this.filterValue.to ? this.filterValue.to.getTime() : undefined
        }];else expr = undefined;

        return expr;
      }
    }, {
      key: 'storeKey',
      get: function get() {
        return this.field ? this.field + '-' + this.resourcekey : '.-' + this.resourcekey;
      }
    }]);

    return Column;
  }(), (_descriptor = _applyDecoratedDescriptor(_class2.prototype, 'viewtype', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return 'text';
    }
  }), _descriptor2 = _applyDecoratedDescriptor(_class2.prototype, 'class', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return '';
    }
  }), _descriptor3 = _applyDecoratedDescriptor(_class2.prototype, 'resourcekey', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return '';
    }
  }), _descriptor4 = _applyDecoratedDescriptor(_class2.prototype, 'field', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return '';
    }
  }), _descriptor5 = _applyDecoratedDescriptor(_class2.prototype, 'format', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return undefined;
    }
  }), _descriptor6 = _applyDecoratedDescriptor(_class2.prototype, 'sortable', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return true;
    }
  }), _descriptor7 = _applyDecoratedDescriptor(_class2.prototype, 'defaultSort', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return undefined;
    }
  }), _descriptor8 = _applyDecoratedDescriptor(_class2.prototype, 'canbefiltered', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return false;
    }
  }), _descriptor9 = _applyDecoratedDescriptor(_class2.prototype, 'filterField', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return undefined;
    }
  }), _descriptor10 = _applyDecoratedDescriptor(_class2.prototype, 'downloadGetDataCallback', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor11 = _applyDecoratedDescriptor(_class2.prototype, 'getviewdata', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return null;
    }
  }), _descriptor12 = _applyDecoratedDescriptor(_class2.prototype, 'visible', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return true;
    }
  }), _descriptor13 = _applyDecoratedDescriptor(_class2.prototype, 'filterOptions', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return undefined;
    }
  }), _descriptor14 = _applyDecoratedDescriptor(_class2.prototype, 'filterOptionField', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return undefined;
    }
  }), _descriptor15 = _applyDecoratedDescriptor(_class2.prototype, 'filterOptionKey', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return undefined;
    }
  }), _descriptor16 = _applyDecoratedDescriptor(_class2.prototype, 'filterExpressionBuilder', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return undefined;
    }
  }), _descriptor17 = _applyDecoratedDescriptor(_class2.prototype, 'filterActive', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return false;
    }
  })), _class2)) || _class;
});
define('resources/elements/column-filter',['exports', 'aurelia-framework'], function (exports, _aureliaFramework) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.ColumnFilter = undefined;

  function _initDefineProp(target, property, descriptor, context) {
    if (!descriptor) return;
    Object.defineProperty(target, property, {
      enumerable: descriptor.enumerable,
      configurable: descriptor.configurable,
      writable: descriptor.writable,
      value: descriptor.initializer ? descriptor.initializer.call(context) : void 0
    });
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  function _applyDecoratedDescriptor(target, property, decorators, descriptor, context) {
    var desc = {};
    Object['ke' + 'ys'](descriptor).forEach(function (key) {
      desc[key] = descriptor[key];
    });
    desc.enumerable = !!desc.enumerable;
    desc.configurable = !!desc.configurable;

    if ('value' in desc || desc.initializer) {
      desc.writable = true;
    }

    desc = decorators.slice().reverse().reduce(function (desc, decorator) {
      return decorator(target, property, desc) || desc;
    }, desc);

    if (context && desc.initializer !== void 0) {
      desc.value = desc.initializer ? desc.initializer.call(context) : void 0;
      desc.initializer = undefined;
    }

    if (desc.initializer === void 0) {
      Object['define' + 'Property'](target, property, desc);
      desc = null;
    }

    return desc;
  }

  function _initializerWarningHelper(descriptor, context) {
    throw new Error('Decorating class property failed. Please ensure that transform-class-properties is enabled.');
  }

  var _class, _desc, _value, _class2, _descriptor, _descriptor2, _descriptor3;

  var ColumnFilter = exports.ColumnFilter = (0, _aureliaFramework.noView)(_class = (_class2 = function ColumnFilter() {
    _classCallCheck(this, ColumnFilter);

    _initDefineProp(this, 'viewtype', _descriptor, this);

    _initDefineProp(this, 'active', _descriptor2, this);

    _initDefineProp(this, 'filter_options', _descriptor3, this);
  }, (_descriptor = _applyDecoratedDescriptor(_class2.prototype, 'viewtype', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return 'text';
    }
  }), _descriptor2 = _applyDecoratedDescriptor(_class2.prototype, 'active', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return true;
    }
  }), _descriptor3 = _applyDecoratedDescriptor(_class2.prototype, 'filter_options', [_aureliaFramework.bindable], {
    enumerable: true,
    initializer: function initializer() {
      return undefined;
    }
  })), _class2)) || _class;
});
define('resources/elements/bootstrap-form-validation-renderer',['exports', 'aurelia-validation'], function (exports, _aureliaValidation) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.BootstrapFormValidationRenderer = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var BootstrapFormValidationRenderer = exports.BootstrapFormValidationRenderer = function () {
    function BootstrapFormValidationRenderer() {
      _classCallCheck(this, BootstrapFormValidationRenderer);
    }

    BootstrapFormValidationRenderer.prototype.render = function render(instruction) {

      for (var _iterator = instruction.unrender, _isArray = Array.isArray(_iterator), _i = 0, _iterator = _isArray ? _iterator : _iterator[Symbol.iterator]();;) {
        var _ref2;

        if (_isArray) {
          if (_i >= _iterator.length) break;
          _ref2 = _iterator[_i++];
        } else {
          _i = _iterator.next();
          if (_i.done) break;
          _ref2 = _i.value;
        }

        var _ref5 = _ref2;
        var result = _ref5.result,
            elements = _ref5.elements;

        if (!elements || elements.length === 0) elements = this.lookupElementsByName(result.propertyName);

        for (var _iterator3 = elements, _isArray3 = Array.isArray(_iterator3), _i3 = 0, _iterator3 = _isArray3 ? _iterator3 : _iterator3[Symbol.iterator]();;) {
          var _ref6;

          if (_isArray3) {
            if (_i3 >= _iterator3.length) break;
            _ref6 = _iterator3[_i3++];
          } else {
            _i3 = _iterator3.next();
            if (_i3.done) break;
            _ref6 = _i3.value;
          }

          var element = _ref6;

          this.remove(element, result);
        }
      }

      for (var _iterator2 = instruction.render, _isArray2 = Array.isArray(_iterator2), _i2 = 0, _iterator2 = _isArray2 ? _iterator2 : _iterator2[Symbol.iterator]();;) {
        var _ref4;

        if (_isArray2) {
          if (_i2 >= _iterator2.length) break;
          _ref4 = _iterator2[_i2++];
        } else {
          _i2 = _iterator2.next();
          if (_i2.done) break;
          _ref4 = _i2.value;
        }

        var _ref7 = _ref4;
        var result = _ref7.result,
            elements = _ref7.elements;

        if (!elements || elements.length === 0) elements = this.lookupElementsByName(result.propertyName);

        for (var _iterator4 = elements, _isArray4 = Array.isArray(_iterator4), _i4 = 0, _iterator4 = _isArray4 ? _iterator4 : _iterator4[Symbol.iterator]();;) {
          var _ref8;

          if (_isArray4) {
            if (_i4 >= _iterator4.length) break;
            _ref8 = _iterator4[_i4++];
          } else {
            _i4 = _iterator4.next();
            if (_i4.done) break;
            _ref8 = _i4.value;
          }

          var _element = _ref8;

          this.add(_element, result);
        }
      }
    };

    BootstrapFormValidationRenderer.prototype.lookupElementsByName = function lookupElementsByName(name) {
      return document.getElementsByName(name);
    };

    BootstrapFormValidationRenderer.prototype.add = function add(element, result) {
      if (result.valid) {
        return;
      }

      var formGroup = element.closest('.form-group');
      if (!formGroup) {
        return;
      }

      var formControl = formGroup.querySelector('.form-control');
      if (!formControl) {
        return;
      }

      formControl.classList.add('is-invalid');

      var message = document.createElement('span');
      message.className = 'invalid-feedback';
      message.textContent = result.message;
      message.style = "display: unset";
      message.id = 'validation-message-' + result.id;

      var inputGroup = element.closest('.input-group');
      if (!inputGroup) {
        return;
      }
      inputGroup.appendChild(message);
    };

    BootstrapFormValidationRenderer.prototype.remove = function remove(element, result) {
      if (result.valid) {
        return;
      }

      var formGroup = element.closest('.form-group');
      if (!formGroup) {
        return;
      }

      var formControl = formGroup.querySelector('.form-control');
      if (!formControl) {
        return;
      }

      var message = element.parentElement.querySelector('#validation-message-' + result.id);

      if (message) {
        message.parentElement.removeChild(message);

        if (formControl.parentElement.querySelectorAll('.invalid-feedback').length === 0) {
          formControl.classList.remove('is-invalid');
        }
      }
    };

    return BootstrapFormValidationRenderer;
  }();
});
define('pages/home',['exports', '../common/crud', 'aurelia-validation', 'aurelia-framework', '../resources/elements/bootstrap-form-validation-renderer', 'aurelia-event-aggregator', '../services/identity-service', '../services/chaincode-service', 'cleave.js'], function (exports, _crud, _aureliaValidation, _aureliaFramework, _bootstrapFormValidationRenderer, _aureliaEventAggregator, _identityService, _chaincodeService) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.Home = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  function _possibleConstructorReturn(self, call) {
    if (!self) {
      throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
    }

    return call && (typeof call === "object" || typeof call === "function") ? call : self;
  }

  function _inherits(subClass, superClass) {
    if (typeof superClass !== "function" && superClass !== null) {
      throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
    }

    subClass.prototype = Object.create(superClass && superClass.prototype, {
      constructor: {
        value: subClass,
        enumerable: false,
        writable: true,
        configurable: true
      }
    });
    if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
  }

  var _dec, _class;

  var Home = exports.Home = (_dec = (0, _aureliaFramework.inject)(_identityService.IdentityService, _aureliaEventAggregator.EventAggregator, _chaincodeService.ChaincodeService, _aureliaValidation.ValidationControllerFactory), _dec(_class = function (_CRUD) {
    _inherits(Home, _CRUD);

    function Home(identityService, eventAggregator, chaincodeService, factory) {
      _classCallCheck(this, Home);

      var _this = _possibleConstructorReturn(this, _CRUD.call(this, identityService, eventAggregator, chaincodeService));

      _this.orgList = [];
      _this.channelList = [];
      _this.discountValidationController = null;
      _this.fractionsDigits = 0;
      _this.operationsHistory = [];

      _this.discountValidationController = factory.createForCurrentScope();
      _this.discountValidationController.validateTrigger = _aureliaValidation.validateTrigger.manual;
      _this.discountValidationController.addRenderer(new _bootstrapFormValidationRenderer.BootstrapFormValidationRenderer());

      _this.setupValidation();
      return _this;
    }

    Home.prototype.setupValidation = function setupValidation() {
      var _this2 = this;

      _aureliaValidation.ValidationRules.customRule('greater_zero', function (value, obj) {
        if (!value) {
          return true;
        }
        return value > 0;
      }, '${$displayName} has to be greater than zero.');

      _aureliaValidation.ValidationRules.customRule('greater_balance', function (value, obj) {
        if (!value) {
          return true;
        }
        return _this2.organizationAccount.value.amount >= value;
      }, '${$displayName} to transfer can\'t be greater than balance.');

      this.discountRules_Validate = _aureliaValidation.ValidationRules.ensure(function (p) {
        return p.amount;
      }).displayName('Amount').required().satisfiesRule('greater_zero').satisfiesRule('greater_balance').rules;
    };

    Home.prototype.attached = function attached() {
      var _this3 = this;

      var decinpopt = {
        numeral: true,
        numeralDecimalScale: this.fractionsDigits,
        numeralIntegerScale: 10,
        numeralPositiveOnly: true,
        delimiter: ''
      };
      var amount = new Cleave('#amount', decinpopt);

      this.queryAll();
      this.subscriberBlock = this.eventAggregator.subscribe('block', function () {
        _this3.queryAll();
      });

      return _CRUD.prototype.attached.call(this);
    };

    Home.prototype.detached = function detached() {
      this.subscriberBlock.dispose();
    };

    Home.prototype.queryAll = function queryAll() {
      this.amount = undefined;
      return Promise.all([this.queryOrgs(), this.queryChannels(), this.queryOrganizations(), this.getOrganizationAccount(), this.getHistoryOperationsList()]);
    };

    Home.prototype.queryOrgs = function queryOrgs() {
      var _this4 = this;

      this.chaincodeService.getOrgs('common').then(function (orgs) {
        _this4.orgList = [];
        orgs.forEach(function (k) {
          var orgName = k.id;
          if (!orgName.startsWith('Orderer') && !orgName.startsWith('orderer') && orgName !== _this4.identityService.org) {
            _this4.orgList.push({ key: orgName, value: orgName });
          }
        });
      });
    };

    Home.prototype.queryChannels = function queryChannels() {
      var _this5 = this;

      this.chaincodeService.getChannels().then(function (channels) {
        _this5.channelList = channels;
      });
    };

    Home.prototype.transfer = function transfer(receiver, amount) {
      var _this6 = this;

      this.discountValidationController.reset();
      try {
        this.discountValidationController.validate({ object: { "amount": amount }, rules: this.discountRules_Validate }).then(function (result) {
          if (result.valid) {
            return _this6.chaincodeService.invoke(_this6.channel, _this6.chaincode, "transfer", [_this6.identityService.org, receiver, amount]);
          }
        });
      } catch (ex) {
        console.debug(ex);
      }
    };

    Home.prototype.queryOrganizations = function queryOrganizations() {
      return this.chaincodeService.query(this.channel, this.chaincode, 'listOrganizations', []);
    };

    Home.prototype.getOrganizationAccount = function getOrganizationAccount() {
      var _this7 = this;

      this.chaincodeService.query(this.channel, this.chaincode, 'getOrganizationAccount', []).then(function (account) {
        _this7.organizationAccount = account;
      });
    };

    Home.prototype.getHistoryOperationsList = function getHistoryOperationsList() {
      var _this8 = this;

      this.chaincodeService.query(this.channel, this.chaincode, 'listOperationsHistory', []).then(function (o) {
        var a = o || [];
        _this8['operationHistoryList'] = a.map(function (e) {
          e.id = e.key;
          return e;
        });
      });
    };

    Home.prototype.getTokens = function getTokens() {
      return this.chaincodeService.invoke(this.channel, this.chaincode, "getTokens", ["1000000"]);
    };

    Home.prototype.queryOperationHistory = function queryOperationHistory() {
      var _this9 = this;

      var x = this.queryAll();
      return new Promise(function (resolve, reject) {
        _this9.queryAll().then(function (ret) {
          resolve(_this9.operationHistoryList);
        }).catch(function (err) {
          reject(err);
        });
      });
    };

    return Home;
  }(_crud.CRUD)) || _class);
});
define('text!pages/home.html', ['module'], function(module) { module.exports = "<template>\n  <require from=\"../resources/elements/key\"></require>\n  <require from=\"../resources/elements/handy-table\"></require>\n  <require from=\"../resources/elements/column\"></require>\n  <require from=\"../resources/elements/widget-entity-crud\"></require>\n\n  <div class=\"form-group row\">\n    <div class=\"card-body aut-form-card\">\n      <button type=\"button\" class=\"btn btn-success\" click.trigger=\"getTokens()\" t=\"Get one million tokens\">\n        Transfer\n      </button>\n    </div>\n  </div>\n  <div class=\"form-group row\">\n    <div class=\"col-sm-6\">\n      <h4 t=\"Balance\">Balance</h4>\n      <div class=\"col-sm-6\">\n        ${organizationAccount.value.amount}\n      </div>\n    </div>\n  </div>\n  <div class=\"form-group row\">\n    <div class=\"col-sm-6\">\n      <h4 t=\"Transfer\">Transfer</h4>\n    </div>\n  </div>\n  <div class=\"form-group row\">\n    <div class=\"col-sm-6\">\n      <label class=\"col-sm-2 col-form-label\" t=\"Receiver\"></label>\n      <div class=\"col-sm-10\">\n        <select class=\"form-control\"\n                value.bind=\"receiver\">\n          <option repeat.for=\"o of orgList\" model.bind=\"o.key\">${o.key}\n          </option>\n        </select>\n      </div>\n    </div>\n  </div>\n\n\n  <div class=\"form-group row\">\n    <div class=\"col-sm-6\">\n      <label class=\"col-sm-2 col-form-label\" t=\"Amount\"></label>\n      <div class=\"input-group col-sm-10\">\n        <input id=\"amount\" name=\"amount\" type=\"text\" class=\"form-control\"\n               value.bind=\"amount & validateManually:discountValidationController\">\n      </div>\n    </div>\n  </div>\n  </div>\n  <div class=\"form-group row\">\n    <div class=\"col-sm-6\">\n      <div if.bind=\"discountValidationController.errors.length > 0\" class=\"alert alert-danger\" role=\"alert\">\n        <span t=\"errorMessages.hasErrors\">hasErrors</span>\n      </div>\n    </div>\n  </div>\n  <div class=\"form-group row\">\n    <div class=\"card-body aut-form-card\">\n      <button type=\"button\" class=\"btn btn-success\" click.trigger=\"transfer(receiver,amount)\" t=\"Transfer\">\n        Transfer\n      </button>\n    </div>\n  </div>\n  <div class=\"form-group row\">\n    <div class=\"col-sm-6\">\n      <h4 t=\"Operation history\">Operation history</h4>\n    </div>\n  </div>\n  <div class=\"form-group row\">\n    <div class=\"col-sm-6\">\n      <div>\n        <handy-table\n          tabident=\"operation-tab\"\n          read-data.call=\"queryOperationHistory()\"\n          pageable=\"true\"\n          can-create.call=\"false\"\n          can-cancel-filter.call=\"false\"\n          can-filter-columns.bind=\"false\">\n          <column field=\"value.sender\" resourcekey=\"Sender\"></column>\n          <column field=\"value.receiver\" resourcekey=\"Receiver\"></column>\n          <column field=\"value.amount\" resourcekey=\"Amount\"></column>\n          <column field=\"value.timestamp\" resourcekey=\"Date time\" viewtype=\"datetime\" format=\"YYYY-MM-DD HH:mm\" ></column>\n        </handy-table>\n      </div>\n    </div>\n  </div>\n\n</template>\n\n\n</template>\n"; });
define('main',['exports', './environment', 'aurelia-i18n'], function (exports, _environment, _aureliaI18n) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.configure = configure;

  var _environment2 = _interopRequireDefault(_environment);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      default: obj
    };
  }

  function configure(aurelia) {

    aurelia.use.standardConfiguration().plugin('aurelia-i18n', function (instance) {
      var aliases = ['t', 'i18n'];

      _aureliaI18n.TCustomAttribute.configureAliases(aliases);

      instance.i18next.use(_aureliaI18n.Backend.with(aurelia.loader));


      return instance.setup({
        backend: {
          loadPath: '../locales/{{lng}}/{{ns}}.json' },
        attributes: aliases,
        lng: 'en',
        fallbackLng: 'en',
        debug: false
      });
    }).plugin('aurelia-table').plugin('aurelia-validation').feature('resources');

    if (_environment2.default.debug) {
      aurelia.use.developmentLogging();
    }

    if (_environment2.default.testing) {
      aurelia.use.plugin('aurelia-testing');
    }

    aurelia.start().then(function () {
      var isLoggedIn = localStorage.getItem('jwt');
      if (isLoggedIn) {
        aurelia.setRoot();
      } else {
        aurelia.setRoot('login');
      }
    });
  }
});
define('login',['exports', 'aurelia-framework', './services/identity-service', './services/alert-service'], function (exports, _aureliaFramework, _identityService, _alertService) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.Login = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _createClass = function () {
    function defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }

    return function (Constructor, protoProps, staticProps) {
      if (protoProps) defineProperties(Constructor.prototype, protoProps);
      if (staticProps) defineProperties(Constructor, staticProps);
      return Constructor;
    };
  }();

  var _dec, _class;

  var log = _aureliaFramework.LogManager.getLogger('Login');

  var Login = exports.Login = (_dec = (0, _aureliaFramework.inject)(_identityService.IdentityService, _alertService.AlertService), _dec(_class = function () {
    function Login(identityService, alertService) {
      _classCallCheck(this, Login);

      this.errorMessage = undefined;

      this.identityService = identityService;
      this.alertService = alertService;
    }

    Login.prototype.login = function login() {
      var _this = this;

      this.identityService.enroll(this.username, this.password).then(function () {
        _this.errorMessage = undefined;
        _this.alertService.success(_this.username + ' logged in');
      }).catch(function (e) {
        _this.errorMessage = e;
        _this.alertService.error('cannot enroll, caught ' + e);
      });
    };

    _createClass(Login, [{
      key: 'org',
      get: function get() {
        return this.identityService.org;
      }
    }]);

    return Login;
  }()) || _class);
});
define('text!login.html', ['module'], function(module) { module.exports = "<template>\n  <require from=\"bootstrap/css/bootstrap.min.css\"></require>\n  <require from=\"./styles/app.css\"></require>\n\n  <div style=\"position: relative; height: 100%; display: flex; justify-content: center;\">\n    <div class=\"container\" style=\"margin: auto;\">\n      <!--h-100-->\n      <div class=\"row justify-content-center align-items-center\">\n        <form class=\"form-signin\" submit.delegate=\"login()\">\n          <h1 class=\"text-center text-uppercase\">${org}</h1>\n          <p>You're connected to your organization's API server. Login or register.</p>\n          <div class=\"form-group\">\n            <input type=\"text\" class=\"form-control\" placeholder=\"Username\" required autofocus value.bind=\"username\">\n          </div>\n          <div class=\"form-group\">\n            <input type=\"password\" class=\"form-control\" placeholder=\"Password\" required value.bind=\"password\">\n          </div>\n          <div if.bind=\"errorMessage\" class=\"alert alert-danger\" role=\"alert\">\n            <span t=\"errorMessages.errorMessage\">errorMessages.errorMessage</span>\n          </div>\n          <div class=\"form-group\">\n            <button class=\"btn btn-lg btn-primary btn-block\" type=\"submit\">Login</button>\n          </div>\n        </form>\n      </div>\n    </div>\n  </div>\n</template>\n"; });
define('environment',["exports"], function (exports) {
  "use strict";

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.default = {
    debug: true,
    testing: false
  };
});
define('config',['exports', './environment'], function (exports, _environment) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.Config = undefined;

  var _environment2 = _interopRequireDefault(_environment);

  function _interopRequireDefault(obj) {
    return obj && obj.__esModule ? obj : {
      default: obj
    };
  }

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var Config = exports.Config = function () {
    function Config() {
      _classCallCheck(this, Config);
    }

    Config.put = function put(key, val) {
      return localStorage.setItem(key, JSON.stringify(val));
    };

    Config.get = function get(key) {
      var val = localStorage.getItem(key);
      if (val === 'undefined' || val === null) {
        val = _environment2.default[key];
        this.put(key, val);
        return val;
      } else {
        return JSON.parse(val);
      }
    };

    Config.clear = function clear() {
      localStorage.clear();
    };

    Config.getUrl = function getUrl(path) {
      var baseUrl = Config.get('baseUrl');
      if (baseUrl) {
        return path ? baseUrl + '/' + path : baseUrl;
      } else {
        return path ? '/' + path : '/';
      }
    };

    return Config;
  }();
});
define('common/crud',['exports', 'aurelia-framework', 'aurelia-event-aggregator', '../services/identity-service', '../services/chaincode-service', 'aurelia-validation'], function (exports, _aureliaFramework, _aureliaEventAggregator, _identityService, _chaincodeService, _aureliaValidation) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.CRUD = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _dec, _class;

  var log = _aureliaFramework.LogManager.getLogger('CRUD');

  var CRUD = exports.CRUD = (_dec = (0, _aureliaFramework.inject)(_identityService.IdentityService, _aureliaEventAggregator.EventAggregator, _chaincodeService.ChaincodeService, _aureliaValidation.ValidationControllerFactory), _dec(_class = function () {
    function CRUD(identityService, eventAggregator, chaincodeService) {
      _classCallCheck(this, CRUD);

      this.channel = 'common';
      this.chaincode = 'token-transfer-chaincode';
      this.organizationAccount = undefined;

      this.identityService = identityService;
      this.eventAggregator = eventAggregator;
      this.chaincodeService = chaincodeService;
    }

    CRUD.prototype.attached = function attached() {
      var _this = this;

      this.queryAll();

      this.subscriberBlock = this.eventAggregator.subscribe('block', function (o) {
        _this.queryAll();
      });
    };

    CRUD.prototype.detached = function detached() {
      this.subscriberBlock.dispose();
    };

    CRUD.prototype.queryAll = function queryAll() {};

    CRUD.prototype.query = function query(entity) {
      var _this2 = this;

      var opName = 'list'.concat(this.capitalize(entity));
      return this.chaincodeService.query(this.channel, this.chaincode, opName, []).then(function (o) {
        var a = o || [];
        _this2[entity + 'List'] = a.map(function (e) {
          e.id = e.key;
          return e;
        });
      });
    };

    CRUD.prototype.put = function put(o, entity) {
      var _this3 = this;

      if (!o.value.type) {
        o.value.type = entity;
      }
      if (o.key) {
        var opName = 'update'.concat(this.capitalize(entity));
        return this.chaincodeService.invoke(this.channel, this.chaincode, opName, [o.key, JSON.stringify(o.value)]).then(function () {
          _this3.removeForm(entity);
        });
      } else {
        var _opName = 'create'.concat(this.capitalize(entity));
        return this.chaincodeService.invoke(this.channel, this.chaincode, _opName, [JSON.stringify(o.value)]).then(function () {
          _this3.removeForm(entity);
        });
      }
    };

    CRUD.prototype.remove = function remove(entity, id) {
      var _this4 = this;

      var opName = 'delete'.concat(this.capitalize(entity));
      return this.chaincodeService.invoke(this.channel, this.chaincode, opName, [id]).then(function () {
        _this4.removeForm(entity);
      });
    };

    CRUD.prototype.removeForm = function removeForm(entity) {
      var currentTagName = this.getCurrentTag(entity);

      this[currentTagName] = null;
      this[currentTagName] = undefined;
    };

    CRUD.prototype.setCurrent = function setCurrent(entity, id) {
      var _this5 = this;

      var opName = 'get'.concat(this.capitalize(entity));
      return this.chaincodeService.query(this.channel, this.chaincode, opName, [id]).then(function (o) {
        _this5[_this5.getCurrentTag(entity)] = { key: id, value: o, id: id };
      });
    };

    CRUD.prototype.setNew = function setNew(entity) {
      this[this.getCurrentTag(entity)] = { new: true, value: {} };
    };

    CRUD.prototype.getCurrentTag = function getCurrentTag(entity) {
      return entity + (this.canEdit(entity) ? 'Edit' : 'View');
    };

    CRUD.prototype.canEdit = function canEdit(entity) {
      return true;
    };

    CRUD.prototype.capitalize = function capitalize(s) {
      return s.charAt(0).toUpperCase() + s.slice(1);
    };

    CRUD.prototype.convertDate = function convertDate(date) {
      var dateArr = date.split('/');
      return new Date(parseInt(dateArr[2], 10), parseInt(dateArr[0], 10) - 1, parseInt(dateArr[1], 10)).getTime();
    };

    return CRUD;
  }()) || _class);
});
define('app',['exports', 'aurelia-i18n', 'aurelia-framework', './services/identity-service', './services/socket-service', './services/alert-service', './services/config-service', 'bootstrap'], function (exports, _aureliaI18n, _aureliaFramework, _identityService, _socketService, _alertService, _configService) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  exports.App = undefined;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _dec, _class;

  var log = _aureliaFramework.LogManager.getLogger('App');

  var App = exports.App = (_dec = (0, _aureliaFramework.inject)(_aureliaI18n.I18N, _identityService.IdentityService, _socketService.SocketService, _alertService.AlertService, _configService.ConfigService), _dec(_class = function () {
    function App(i18n, identityService, socketService, alertService, configService) {
      _classCallCheck(this, App);

      this.i18n = i18n;

      this.i18n.setLocale('en');
      this.identityService = identityService;
      this.socketService = socketService;
      this.alertService = alertService;
      this.configService = configService;
      this.role = '';
    }

    App.prototype.configureRouter = function configureRouter(config, router) {
      config.title = "Token transfer";
      var routes = [{ route: ['', 'home'], name: 'home', moduleId: './pages/home', nav: true, title: 'Home' }];
      config.map(routes);
      this.router = router;
    };

    App.prototype.activate = function activate() {
      var _this = this;

      return this.configService.get().then(function (res) {
        _this.role = res.org;
      });
    };

    App.prototype.attached = function attached() {
      this.username = this.identityService.username;
      this.org = this.identityService.org;

      this.socketService.subscribe();
    };

    App.prototype.detached = function detached() {
      log.debug('detached');
    };

    App.prototype.logout = function logout() {
      var _this2 = this;

      this.identityService.logout().then(function () {
        _this2.alertService.success('logged out');
      }).catch(function (e) {
        _this2.alertService.error('cannot log out, caught ' + e);
      });
    };

    return App;
  }()) || _class);
});
define('text!app.html', ['module'], function(module) { module.exports = "<template>\n  <require from=\"font-awesome/css/font-awesome.css\"></require>\n  <require from=\"bootstrap/css/bootstrap.min.css\"></require>\n  <require from=\"eonasdan-bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css\"></require>\n  <require from=\"./styles/app.css\"></require>\n  <require from=\"./styles/spinners.css\"></require>\n  <require from=\"./resources/elements/footer-alerts\"></require>\n\n  <div class=\"page-wrapper\">\n    <div class=\"page-header\">\n      <!--mb-2-->\n      <nav class=\"navbar navbar-expand-md navbar-light\" style=\"background-color: #e3f2fd;\">\n        <a class=\"navbar-brand mb-0 h1 mr-3\" href=\"#/\" t=\"appName\"></a>\n        <button class=\"navbar-toggler\" type=\"button\" data-toggle=\"collapse\" data-target=\"#navbarCollapse\" aria-controls=\"navbarCollapse\" aria-expanded=\"false\" aria-label=\"Toggle navigation\">\n          <span class=\"navbar-toggler-icon\"></span>\n        </button>\n        <div class=\"collapse navbar-collapse\" id=\"navbarCollapse\">\n          <ul class=\"navbar-nav mr-auto ml-auto\">\n            <li repeat.for=\"row of router.navigation\" class=\"nav-item ${row.isActive ? 'active' : ''} text-uppercase font-weight-bold text-center mt-2\">\n              <h5><a class=\"nav-link ${row.isActive ? '' : 'dimmed'}\" href.bind=\"row.href\">${row.title}</a></h5>\n            </li>\n          </ul>\n          <h3><a href=\"#\" class=\"badge badge-light mt-2\">${org}</a></h3>\n          <ul class=\"navbar-nav mt-3 ml-3 mt-md-0\">\n            <li><a class=\"btn btn-sm btn-secondary float-right text-uppercase\" href click.delegate=\"logout()\"><span t=\"logout\">logout</span></a></li>\n          </ul>\n        </div>\n      </nav>\n    </div>\n<!-- class=\"container\" -->\n\n      <!--padding-right: 10px; padding-left: 10px; padding-top: 10px;-->\n        <div class=\"page-content flex-fill-column\">\n          <main role=\"main\" style=\"width: 100%; margin: 0 auto; padding: 10px;\" class=\"flex-fill-column\">\n            <router-view class=\"flex-fill-column\"></router-view>\n          </main>\n        </div>\n\n\n        <footer-alerts>\n        </footer-alerts>\n\n  </div>\n</template>\n"; });
//# sourceMappingURL=app-bundle.js.map