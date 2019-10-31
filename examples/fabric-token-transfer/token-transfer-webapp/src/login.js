import {LogManager} from 'aurelia-framework';
import {inject} from 'aurelia-framework';
import {IdentityService} from './services/identity-service';
import {AlertService} from './services/alert-service';

let log = LogManager.getLogger('Login');

@inject(IdentityService, AlertService)
export class Login {

  errorMessage = undefined;

  constructor(identityService, alertService) {
    this.identityService = identityService;
    this.alertService = alertService;
  }

  get org() {
    return this.identityService.org;
  }

  login() {
    this.identityService.enroll(this.username, this.password).then(() => {
      this.errorMessage = undefined;
      this.alertService.success(`${this.username} logged in`)
    }).catch(e => {
      this.errorMessage = e;
      this.alertService.error(`cannot enroll, caught ${e}`);
    });
  }

}
