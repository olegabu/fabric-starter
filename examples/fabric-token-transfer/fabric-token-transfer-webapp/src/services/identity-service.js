import {inject} from 'aurelia-framework';
import {LogManager} from 'aurelia-framework';
import {Aurelia} from 'aurelia-framework';
import {HttpClient, json} from 'aurelia-fetch-client';
import {AlertService} from './alert-service';
import {ConfigService} from './config-service';
import {Config} from '../config';

let log = LogManager.getLogger('IdentityService');

const baseUrl = Config.getUrl('users');

@inject(Aurelia, HttpClient, ConfigService)
export class IdentityService {

  constructor(aurelia, http, configService) {
    this.aurelia = aurelia;
    this.http = http;
    this.configService = configService;

    this.configService.get().then(config => {
      this.org = config.org;
    });
  }

  static getJwt(org, username) {
    return localStorage.getItem(IdentityService.key(org, username));
  }

  static key(org, username) {
    return 'jwt' + (org ? org.name + username : '');
  }

  static setJwt(jwt, org, username) {
    localStorage.setItem(IdentityService.key(org, username), jwt);
  }

  enroll(username, password, org) {
    const jwt = IdentityService.getJwt(org, username);
    if(jwt) {
      log.debug(`already enrolled ${org.name} ${username}`, jwt);
      return Promise.resolve();
    }

    const url = org ? `${org.url}/users` : baseUrl;

    let params = {
      username: username,
      password: password
    };

    return new Promise((resolve, reject) => {
      this.http.fetch(url, {
        method: 'post',
        body: json(params)
      })
      .then(response => {
        response.json().then(j => {
          if(!response.ok) {
            reject(new Error(`cannot enroll ${response.status} ${j}`));
          } else {
            log.debug(j);

            IdentityService.setJwt(j, org, username);

            this.username = username;

            if(!org) {
              this.aurelia.setRoot('app');
            }

            resolve();
          }
        });
      })
      .catch(err => {
        reject(err);
      });
    });
  }

  logout() {
    localStorage.clear();
    return this.aurelia.setRoot('login');
  }
}
