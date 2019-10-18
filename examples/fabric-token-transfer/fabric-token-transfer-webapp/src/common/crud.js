import {LogManager} from 'aurelia-framework';
import {inject} from 'aurelia-framework';
import {EventAggregator} from 'aurelia-event-aggregator';
import {IdentityService} from '../services/identity-service';
import {ChaincodeService} from '../services/chaincode-service';
import {ValidationControllerFactory, ValidationRules} from 'aurelia-validation';

let log = LogManager.getLogger('CRUD');

@inject(IdentityService, EventAggregator, ChaincodeService, ValidationControllerFactory)
export class CRUD {
  channel = 'common';
  chaincode = 'token-transfer-chaincode';
  organizationAccount = undefined;

  constructor(identityService, eventAggregator, chaincodeService) {
    this.identityService = identityService;
    this.eventAggregator = eventAggregator;
    this.chaincodeService = chaincodeService;
  }

  attached() {
    this.queryAll();

    this.subscriberBlock = this.eventAggregator.subscribe('block', o => {
      this.queryAll();
    });
  }

  detached() {
    this.subscriberBlock.dispose();
  }

  queryAll() {
  }

  query(entity) {
    let opName = 'list'.concat(this.capitalize(entity));
    return this.chaincodeService.query(this.channel, this.chaincode, opName, []).then(o => {
      const a = o || [];
      this[entity + 'List'] = a.map(e => {
        e.id = e.key;
        return e;
      });
    });
  }

  put(o, entity) {
    if (!o.value.type) {
      o.value.type = entity
    }
    if (o.key) {
      let opName = 'update'.concat(this.capitalize(entity));
      return this.chaincodeService.invoke(this.channel, this.chaincode, opName, [o.key, JSON.stringify(o.value)]).then(() => {
        this.removeForm(entity);
      });
    } else {
      let opName = 'create'.concat(this.capitalize(entity));
      return this.chaincodeService.invoke(this.channel, this.chaincode, opName, [JSON.stringify(o.value)]).then(() => {
        this.removeForm(entity);
      });
    }
  }

  remove(entity, id) {
    let opName = 'delete'.concat(this.capitalize(entity));
    return this.chaincodeService.invoke(this.channel, this.chaincode, opName, [id]).then(() => {
      this.removeForm(entity)
    });
  }

  removeForm(entity) {
    let currentTagName = this.getCurrentTag(entity);
    // console.info('removeForm :: ', currentTagName);
    this[currentTagName] = null;
    this[currentTagName] = undefined;
  }

  setCurrent(entity, id) {
    let opName = 'get'.concat(this.capitalize(entity));
    return this.chaincodeService.query(this.channel, this.chaincode, opName, [id]).then(o => {
      this[this.getCurrentTag(entity)] = {key: id, value: o, id: id};
      // return this[this.getCurrentTag(entity)];
    });
  }

  setNew(entity) {
    this[this.getCurrentTag(entity)] = {new: true, value: {}};
  }

  getCurrentTag(entity) {
    return entity + (this.canEdit(entity) ? 'Edit' : 'View');
  }

  canEdit(entity) {
    return true;
  }

  capitalize(s) {
    return s.charAt(0).toUpperCase() + s.slice(1);
  }

  convertDate(date) {
    let dateArr = date.split('/');
    return new Date(parseInt(dateArr[2], 10), parseInt(dateArr[0], 10) - 1, parseInt(dateArr[1], 10)).getTime()
  }
}
