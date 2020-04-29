import {bindable, bindingMode} from 'aurelia-framework';

@bindable({ name: 'o', attribute: 'data'})
export class KeyCustomElement {
  oChanged() {
    if(this.o) {
      const key = this.o;
      const parts = key.split('\u0000');
      if(parts.length > 2) {
        this.objectType = parts[1];
        this.id = parts[2];
      } else {
        this.id = key;
      }
    }
  }
}
