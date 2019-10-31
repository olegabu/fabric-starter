import 'bootstrap';
import {I18N} from 'aurelia-i18n';
import {LogManager} from 'aurelia-framework';
import {inject} from 'aurelia-framework';
import {IdentityService} from './services/identity-service';
import {SocketService} from './services/socket-service';
import {AlertService} from './services/alert-service';
import {ConfigService} from './services/config-service';


let log = LogManager.getLogger('App');

@inject(I18N, IdentityService, SocketService, AlertService, ConfigService)
export class App {
  constructor(i18n, identityService, socketService, alertService, configService) {
    this.i18n = i18n;
    // this.i18n.setLocale(navigator.language || 'en');
    this.i18n.setLocale('en');
    this.identityService = identityService;
    this.socketService = socketService;
    this.alertService = alertService;
    this.configService = configService;
    this.role = '';
  }

  configureRouter(config, router) {
    config.title = "Token transfer";
    let routes = [
      {route: ['', 'home'], name: 'home', moduleId: './pages/home', nav: true, title: 'Home'}
    ];
    config.map(routes);
    this.router = router;
  }

  activate() {
    return this.configService.get().then(res => {
        this.role = res.org;
      }
    )
  }

  attached() {
    this.username = this.identityService.username;
    this.org = this.identityService.org;

    this.socketService.subscribe();
  }

  detached() {
    log.debug('detached');
    // this.socketService.disconnect();
  }

  logout() {
    this.identityService.logout().then(() => {
      this.alertService.success(`logged out`);
    }).catch(e => {
      this.alertService.error(`cannot log out, caught ${e}`);
    });
  }

}
