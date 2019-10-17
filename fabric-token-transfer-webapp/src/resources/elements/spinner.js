import {containerless, child, children, bindable, inject, BindingEngine, customElement, processContent, TargetInstruction } from 'aurelia-framework';

export class SpinnerCustomElement {
  @bindable busy = false;
  @bindable mode = 'context'; // or screen

}

