import {
  containerless,
  child,
  children,
  bindable,
  inject,
  BindingEngine,
  customElement,
  processContent,
  TargetInstruction
} from 'aurelia-framework';
import {Column} from './column'
import {IdentityService} from "../../services/identity-service";
import {ChaincodeService} from "../../services/chaincode-service";
import {ValidationControllerFactory} from "aurelia-validation";
import {EventAggregator} from 'aurelia-event-aggregator';
import {ExpressionEvaluator} from './expression-evaluator';

//@containerless()
@inject(EventAggregator, ExpressionEvaluator)
export class HandyTableCustomElement {

  constructor(eventAggregator, evaluator) {
    this.eventAggregator = eventAggregator;
    this.evaluator = evaluator;
  }

  @bindable tabident = null;
  @children('column') columns = [];
  @bindable canHideColumns = true;
  @bindable canFilterColumns = true;

  visiblecolumns = [];
  filteredColumns = [];

  //@bindable loadData = () => {};

  //@bindable columns = [];
  @bindable pageable = true;
  @bindable pageSize = 20;
  @bindable page = 1;
  @bindable pagerSize = 20;

  //columns: any[] = null;

  loading = false;
  @bindable loadingMessage = "Loading data...";
  @bindable loadingDiv = "<span>Loading data...</span>";

  @bindable readData = null;
  @bindable dataSet = null;
  @bindable onReadError = null;

  @bindable selectedCallback = null;
  @bindable createNewCallback = null;
  //@bindable filterNewCallback = null;
  //@bindable cancelFilterNewCallback = null;

  @bindable canCreate = () => true;
  @bindable canDelete = () => true;
  @bindable canCancelFilter = () => true;

  @bindable minHeight = '400px';

  @bindable pickerDateTime1;
  @bindable pickerDateTime2;

  dataList = [];

  skipRowClick = false;
  localStoreKey = '_profile.h-tab.';
  localStoreFilterSubKey = '.filterst';

  //sortIndex = 0;
  sortColumn = undefined;

  // sleep(ms) {
  //   return new Promise(resolve => setTimeout(resolve, ms));
  // }


  canFilter(){
    return this.readData;
    // console.log('canFilter');
    // console.log(this.columns);
    // console.log(this.columns.length);
    // this.columns.forEach(function(entry) {
    //   console.log(entry);
    // });
    // console.log('--------------------');
    //
    // return this.columns.filter(x=>x.canbefiltered == true).length > 0 ? true : false;
  }

  getFilters () {
    let filters = {
      type: "filter",
      expressions: []
    };

    this.columns.forEach(function(entry) {
      if (entry.filterActive){
        filters.expressions.push(...entry.filterExpression);
      }
    });

    filters.expressions = filters.expressions.filter(x=> (x && (x.value || x.values)));
    //console.log('---------- filters ----------------------');
    //console.log(filters);

    return filters;
  }

  getData() {
    if (!this.readData)
      throw new Error("No readData method specified for table");

    //this.initialLoad = true;

    this.loading = true;

    this.readData({filter: this.getFilters ()})
      .then((result) => {
        this.dataList = result;

        //setTimeout(() => this.loading = false, 15000);
        this.loading = false;
      })
      .catch((error) => {
        console.log(error);

        if (this.onReadError)
          this.onReadError(error);

        this.loading = false;
      });
  }

  sort(column) {
    //this.sortIndex = index;
    this.sortColumn = column;
  }

  sortColumnData = (a, b, order) => {
    let vala = this.sortColumn.field ? this.evaluator.evaluateInterpolation('${' + this.sortColumn.field + '}', a) : this.sortColumn.sortTextView({data: a});
    let valb = this.sortColumn.field ? this.evaluator.evaluateInterpolation('${' + this.sortColumn.field + '}', b) : this.sortColumn.sortTextView({data: b});

    if (order === 1) {
      if (vala < valb) {
        return -1;
      }
      if (vala > valb) {
        return 1;
      }
    }
    if (order === -1) {
      if (vala < valb) {
        return 1;
      }
      if (vala > valb) {
        return -1;
      }
    }
    return 0;
  };


  columnsChanged(newValue) {
    this.restoreVisibleColumns(this.columns);
    this.bindVisibleColumns(this.columns);

    this.restoreFilteredColumns(this.columns);
    this.bindFilteredColumns(this.columns);

    let sortDefCol = this.columns.find(x => x.defaultSort);
    if (sortDefCol) {
      this.sort(sortDefCol);
    }

    //this.initFilters();

    if (this.readData) {
      this.getData();
    }
  }

  dataSetChanged(newValue) {
    this.dataList = this.dataSet;
  }

  bindVisibleColumns(columns) {
    this.visiblecolumns = columns.filter(x => x.visible);

  }

  bindFilteredColumns(columns) {
    this.filteredColumns = columns.filter(x => x.canbefiltered);

    // this.filteredColumns.forEach(function(entry) {
    //   console.log(entry.filterValue);
    // });
  }


  getViewDataDisplay(o, column) {
    if (column.getviewdata)
      return column.getviewdata({data: o});
    else
      return undefined;
  }

  createNewClicked($event) {
    if (this.createNewCallback)
      this.createNewCallback();
  }

  // filterNewClicked($event) {
  //   if (this.filterNewCallback)
  //     this.filterNewCallback();
  //   this.getData();
  // }

  setAllFiltersClicked ($event){
    this.filteredColumns.forEach(function(entry) {
      entry.filterActive = true;
    });

    if (this.readData) {
      this.getData();
    }

    this.storeFilteredColumns(this.columns);

    $event.stopPropagation();
  }

  applyFiltersClicked($event){
    if (this.readData) {
      this.getData();
    }

    this.storeFilteredColumns(this.columns);

    $event.stopPropagation();
  }

  filterOptionClicked($event){
    $event.stopPropagation();
    return true;
  }

  clearFiltersClicked($event){
    this.filteredColumns.forEach(function(entry) {
      entry.filterActive = false;
    });

    if (this.readData) {
      this.getData();
    }

    this.storeFilteredColumns(this.columns);

    $event.stopPropagation();
  }

  // cancelFilterNewClicked($event) {
  //   if (this.cancelFilterNewCallback())
  //     this.cancelFilterNewCallback();
  //   this.filterNewCallback();
  //   this.getData();
  //
  // }

  keyClicked($o) {
    this.skipRowClick = true;

    $o.$isSelected = !$o.$isSelected;
  }

  rowSelected($event) {
    if (this.selectedCallback)
      this.selectedCallback({data: $event.detail.row});
  }

  rowClicked($o) {

    try {
      if (!this.skipRowClick) {
        if ($o && $o.$isSelected) {
          if (this.selectedCallback)
            this.selectedCallback({data: null});
        }
      }
    } finally {
      this.skipRowClick = false;
    }
  }

  normalizeMimeType(mimetype, filename) {
    if (mimetype == 'XML' || mimetype == 'xML$') {
      return 'application/xml';
    } else if (mimetype == 'TEXT' || mimetype == 'tEXT$') {
      return 'text/plain';
    } else if (mimetype == 'Binary' || mimetype == 'binary$') {
      if (filename.toLowerCase().endsWith('.zip')) {
        return 'application/zip';
      } else
        return 'application/octet-stream';
    } else
      return mimetype;
  }

  converBase64toBlob(content, contentType) {
    contentType = contentType || '';
    var sliceSize = 512;
    var byteCharacters = window.atob(content); //method which converts base64 to binary
    var byteArrays = [];
    for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
      var slice = byteCharacters.slice(offset, offset + sliceSize);
      var byteNumbers = new Array(slice.length);
      for (var i = 0; i < slice.length; i++) {
        byteNumbers[i] = slice.charCodeAt(i);
      }
      var byteArray = new Uint8Array(byteNumbers);
      byteArrays.push(byteArray);
    }
    var blob = new Blob(byteArrays, {
      type: contentType
    });
    return blob;
  }

  dataContenttoFile(dataContent, filename, mime) {
    let data = this.converBase64toBlob(dataContent, mime);

    return new File([data], filename, {type: mime});
  }

  hasValue($o, column) {
    let val = column.field ? this.evaluator.evaluateInterpolation('${' + column.field + '}', $o) : undefined;
    return val;
  }

  downloadClicked($o, column) {
    let fileName = 'file.txt';

    if (column.downloadGetDataCallback) {
      column.downloadGetDataCallback({data: $o})
        .then(fileresp => {
          //console.log ('fileresp');
          //console.log (fileresp);
          let file = this.dataContenttoFile(fileresp.content, fileresp.filename, this.normalizeMimeType(fileresp.mimetype, fileresp.filename));
          //console.log('file');
          //console.log(file);
          fileName = fileresp.filename;
          return URL.createObjectURL(file);
        })
        .then(url => {
          let anchor = document.createElement("a");
          anchor.href = url;
          anchor.setAttribute("download", fileName);
          anchor.innerHTML = "downloading...";
          anchor.style.display = "none";
          document.body.appendChild(anchor);
          setTimeout(function () {
            anchor.click();
            document.body.removeChild(anchor);
            setTimeout(function () {
              self.URL.revokeObjectURL(anchor.href);
            }, 200);
          }, 50);

          return true;
        });
    }
  }

  hasOptionalColumns() {
    return this.canHideColumns;
  }

  storeVisibleColumns(columns) {
    var cvarray = columns.map(x => ({key: x.storeKey, vis: x.visible}));
    var visJson = JSON.stringify(cvarray);

    window.localStorage.setItem(this.localStoreKey + this.tabident, visJson);
  }

  restoreVisibleColumns(columns) {
    // console.log('restoreVisibleColumns');
    var visJson = window.localStorage.getItem(this.localStoreKey + this.tabident);
    if (visJson) {
      var cvarray = JSON.parse(visJson);
      if (Array.isArray(cvarray)) {
        cvarray.forEach(x => {
          var c = columns.find(y => y.storeKey == x.key);
          if (c) {
            c.visible = x.vis
          }
        });
      }
    }
  }

  storeFilteredColumns(columns) {
    var cvarray = columns.map(x => ( x.filterToJsonObject()));
    console.log ('storeFilteredColumns');
    console.log (cvarray);

    var fltJson = JSON.stringify(cvarray);

    window.localStorage.setItem(this.localStoreKey + this.tabident + this.localStoreFilterSubKey, fltJson);
  }

  restoreFilteredColumns(columns) {
    var fltJson = window.localStorage.getItem(this.localStoreKey + this.tabident + this.localStoreFilterSubKey);
    if (fltJson) {
      var cvarray = JSON.parse(fltJson);
      if (Array.isArray(cvarray)) {
        cvarray.forEach(x => {
          var c = columns.find(y => y.storeKey == x.key);
          if (c) {
            c.jsonObjectToFilter(x);
            // c.filterActive = x.act;
            // c.filterValue = x.fval;
            // console.log ('c.filterValue');
            // console.log (c.filterValue);
          }
        });
      }
    }
  }

  columnVisibilityClicked($event, $o) {
    $o.visible = !$o.visible;

    this.storeVisibleColumns(this.columns);
    this.bindVisibleColumns(this.columns);

    $event.stopPropagation();
  }

  columnFiltersClicked($event, $o) {
    $o.filterActive = !$o.filterActive;

    this.storeFilteredColumns(this.columns);
    this.bindFilteredColumns(this.columns);

    if (this.readData) {
      this.getData();
    }


    $event.stopPropagation();
  }

  attached() {

    // if (this.readData) {
    //   this.getData();
    // } else if (this.dataSet) {
    //   this.dataList = this.dataSet;
    // }

    if (this.dataSet) {
      this.dataList = this.dataSet;
    }

    if (this.readData) {
      this.subscriberBlock = this.eventAggregator.subscribe('block', o => {
        this.getData();
      });
    }

    this.initFilters ();
    // this.taskQueue.queueMicroTask(() => {
    //   initFilters ();
    // });
  }

  detached() {
    if (this.subscriberBlock)
      this.subscriberBlock.dispose();
  }

  // bind(bindingContext, overrideContext) {
  //   this.bindVisibleColumns(this.columns);
  // }

  pickerDateTime1Changed() {
    //this.pickerDateTime1.methods.daysOfWeekDisabled([0,6]);
    // if (this.pickerDateTime2)
    //   this.pickerDateTime2.methods.minDate(this.pickerDateTime1.date);
  }

  pickerDateTime2Changed() {

  }

  pickerDateChanged() {
  }


  initFilters (){
    $(document).on('click.bs.dropdown.data-api', '.keepopen', function (e) {
      e.stopPropagation();
    });
  }
}
