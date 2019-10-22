import {inject} from 'aurelia-framework';
import {LogManager} from 'aurelia-framework';
import {EventAggregator} from 'aurelia-event-aggregator';
import {AlertService} from './alert-service';
import io from 'socket.io-client';
import {Config} from '../config';

let log = LogManager.getLogger('SocketService');

@inject(EventAggregator, AlertService)
export class SocketService {

  constructor(eventAggregator, alertService) {
    this.eventAggregator = eventAggregator;
    this.alertService = alertService;

    this.socket = io.connect(Config.getUrl());
  }

  subscribe() {
    log.info('subscribe socket.connected', this.socket.connected);

    if (!this.subscribed) {
      this.socket.on('chainblock', o => {
        log.debug('chainblock', o);

        this.alertService.success(`new block ${o.number} on ${o.channel_id}`, "PUT");
        this.eventAggregator.publish('block', o);
      });
    }

    this.subscribed = true;
  }

  disconnect() {
    this.subscribed = false;
    this.socket.disconnect();
  }

}
