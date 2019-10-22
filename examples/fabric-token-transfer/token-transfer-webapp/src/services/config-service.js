import {inject} from 'aurelia-framework';
import {LogManager} from 'aurelia-framework';
import {HttpClient, json} from 'aurelia-fetch-client';
import {Config} from '../config';

let log = LogManager.getLogger('ConfigService');

@inject(HttpClient)
export class ConfigService {

  constructor(http) {
    this.http = http;
  }

  get() {
    return new Promise((resolve, reject) => {
      this.http.fetch(Config.getUrl('mspid'))
      .then(response => response.json())
      .then(mspid => {
        log.debug('mspid', mspid);
        this.config = {
          org: mspid
        };

        resolve(this.config);
      })
      .catch(err => {
        reject(err);
      });
    });
  }

}
