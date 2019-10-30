import {LogManager} from 'aurelia-framework';
import {inject} from 'aurelia-framework';
import {HttpClient, json} from 'aurelia-fetch-client';
import {IdentityService} from './identity-service';
import {AlertService} from './alert-service';
import {Config} from '../config';

let log = LogManager.getLogger('ChaincodeService');

const baseUrl = Config.getUrl('channels/');

@inject(HttpClient, IdentityService, AlertService)
export class ChaincodeService {

  constructor(http, identityService, alertService) {
    this.identityService = identityService;
    this.http = http;
    this.alertService = alertService;
    this.mspID = this.identityService.org
  }

  fetch(url, params, method, org, username) {
    log.debug('fetch', params);
    log.debug(JSON.stringify(params));

    return new Promise((resolve, reject) => {
      const jwt = IdentityService.getJwt(org, username);

      let promise;

      if (method === 'get') {
        let query = '';
        if (params) {
          query = '?' + Object.keys(params).map(k => encodeURIComponent(k) + '=' + encodeURIComponent(params[k])).join('&');
        }

        promise = this.http.fetch(`${url}${query}`, {
          headers: {
            'Authorization': 'Bearer ' + jwt
          }
        });
      } else {
        promise = this.http.fetch(url, {
          method: method,
          body: json(params),
          headers: {
            'Authorization': 'Bearer ' + jwt
          }
        });
      }

      promise.then(response => {
        if (response.status === 401) {
          this.alertService.info('session expired, logging you out');
          this.identityService.logout();
          reject(new Error('Session expired, logging you out'));
        }
        response.json().then(j => {
          log.debug('fetch', j);

          if (!response.ok) {
            const msg = `${response.statusText} ${j}`;

            if (response.status === 401) {
              this.alertService.info('session expired, logging you out');
              this.identityService.logout();
            } else {
              this.alertService.error(msg);
            }

            reject(new Error(msg));
          } else {
            resolve(j);
          }
        });

      }).catch(err => {
        this.alertService.error(`caught ${err}`);
        reject(err);
      });
    });
  }

  getBilateralChannels() {
    return this.getChannels().then(channels => {
      return channels.filter(channel => {
        const orgs = channel.split('-');
        return orgs.length === 2 && (orgs[0] === this.identityService.org || orgs[1] === this.identityService.org);
      });
    });
  }

  getChannels(org, username) {
    log.debug(`getChannels ${org} ${username}`);

    const url = baseUrl;

    return new Promise((resolve, reject) => {
      this.fetch(url, null, 'get', org, username).then(j => {
        const channels = j.map(o => {
          return o.channel_id;
        });

        resolve(channels);
      })
        .catch(err => {
          reject(err);
        });
    });
  }

  query(channel, chaincode, func, args, org, username) {
    log.debug(`query channel=${channel} chaincode=${chaincode} func=${func} ${org} ${username}`, args);

    const url = org ? `${org.url}/channels/` : baseUrl;

    const params = {
      fcn: func,
      args: json(args),
      targets: json([])
    };

    return new Promise((resolve, reject) => {
      this.alertService.pending('data fetching ..');

      this.fetch(`${url}${channel}/chaincodes/${chaincode}`, params, 'get', org, username).then(j => {
        log.debug('query result:', j);
        this.alertService.success('data fetched successfully');
        let result = JSON.parse(j[0]);
        log.debug('result:', result);
        resolve(result);
      }).catch(err => {
        reject(err);
      });
    });
  }

  getOrgs(channel, org, username) {
    log.debug(`get ORGS for channel=${channel}`);

    const url = org ? `${org.url}/channels/` : baseUrl;

    return new Promise((resolve, reject) => {
      this.fetch(`${url}${channel}/orgs`, undefined, 'get', org, username).then(j => {
        // log.debug('query', j);
        resolve(j);
      }).catch(err => {
        reject(err);
      });
    });
  }

  invoke(channel, chaincode, func, args, org, username) {
    log.debug(`invoke channel=${channel} chaincode=${chaincode} func=${func} ${org} ${username}`, args);

    const url = org ? `${org.url}/channels/` : baseUrl;

    const params = {
      fcn: func,
      args: args,
      targets: json([])
    };

    return new Promise((resolve, reject) => {
      this.alertService.pending('data updating ..', 'PUT');
      this.fetch(`${url}${channel}/chaincodes/${chaincode}`, params, 'post', org, username).then(j => {
        resolve(j.transaction);
      })
        .catch(err => {
          reject(err);
        });
    });
  }

  invokeWithTransient(channel, chaincode, func, args, transient, org, username) {
    log.debug(`invoke channel=${channel} chaincode=${chaincode} func=${func} ${org} ${username}`, transient);

    const url = org ? `${org.url}/channels/` : baseUrl;

    const params = {
      fcn: func,
      args: args,
      targets: json([]),
      transientMap: transient
    };

    return new Promise((resolve, reject) => {
      this.alertService.pending('data updating ..', 'PUT');
      this.fetch(`${url}${channel}/chaincodes/${chaincode}`, params, 'post', org, username).then(j => {
        resolve(j.transaction);
      })
        .catch(err => {
          reject(err);
        });
    });
  }

}
