import {noView, children, child, bindable, inject, BindingEngine, customElement, processContent, TargetInstruction } from 'aurelia-framework';

@noView
export class Column {
  @bindable viewtype = 'text'; // 'download', 'key', 'datetime', 'date'

  @bindable class = '';
  @bindable resourcekey = '';
  @bindable field = '';
  @bindable format = undefined;
  @bindable sortable = true;
  @bindable defaultSort = undefined; // asc desc
  @bindable canbefiltered = false;
  @bindable filterField = undefined;


  //@bindable downloadData = null;
  @bindable downloadGetDataCallback = null;

  //@bindable heading;
  @bindable getviewdata = null;

  @bindable visible = true;

  @bindable filterOptions = undefined;
  @bindable filterOptionField = undefined;
  @bindable filterOptionKey = undefined;
  @bindable filterExpressionBuilder = undefined;

  @bindable filterActive = false;
  filterValue = undefined;

  sortTextView (row){
    if (this.getviewdata) {
      //console.log(this.getviewdata(row));
      return this.getviewdata(row);
    }
  }

  filterValueChanged(newValue) {
    console.log('------------------------------filterValueChanged------------------------------');
    console.log(newValue);

  }

  filterToJsonObject (){
    let fv = {
      key: this.storeKey,
      act: this.filterActive
    };

    if (this.viewtype == 'text' || this.viewtype == 'key')
      fv.fval = this.filterValue;
    else if (this.viewtype == 'download')
      fv.fval = this.filterValue;
    else if (this.viewtype == 'date' || this.viewtype == 'datetime')
      fv.fval = {
        from: this.filterValue && this.filterValue.from ? this.filterValue.from.getTime() : null,
        to: this.filterValue && this.filterValue.to ? this.filterValue.to.getTime(): null
      };

    return fv;
  }

  jsonObjectToFilter (json) {
    this.filterActive = json.act;
    if (this.viewtype == 'text' || this.viewtype == 'key')
      this.filterValue = json.fval;
    else if (this.viewtype == 'download')
      this.filterValue = json.fval;
    else if (this.viewtype == 'date' || this.viewtype == 'datetime')
      if (json.fval) {
        this.filterValue = {};
        this.filterValue.from = json.fval.from ? new Date(json.fval.from) : undefined;
        this.filterValue.to = json.fval.to ? new Date(json.fval.to) : undefined;
      }
      else
        this.filterValue = null;
  }

  get filterExpression(){
    let expr = undefined;

    if (this.filterExpressionBuilder)
      return this.filterExpressionBuilder({data: this.filterValue});

    if (this.viewtype == 'text' || this.viewtype == 'key')
      expr = [{
          type: "eq",
          path: this.filterField ? this.filterField : this.field,
          value: this.filterValue
        }];
    else if (this.viewtype == 'download')
      expr = [{
        type: "eq",
        path: this.filterField ? this.filterField : this.field,
        value: this.filterValue
      }];
    else if (this.viewtype == 'date' || this.viewtype == 'datetime')
      expr = [
        {
          type: "gt",
          path: this.filterField ? this.filterField : this.field,
          value: (this.filterValue && this.filterValue.from ? this.filterValue.from.getTime() : undefined)
        },
        {
          type: "lt",
          path: this.filterField ? this.filterField : this.field,
          value: (this.filterValue && this.filterValue.to ? this.filterValue.to.getTime() : undefined)
        }];
    else
      expr = undefined;

      return expr;
  }

  get storeKey () {
    return this.field ? (this.field + '-' + this.resourcekey) : '.-' + this.resourcekey;
  }

}
