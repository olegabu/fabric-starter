import {inject} from 'aurelia-framework';
import {ExpressionEvaluator} from './expression-evaluator';
import moment from 'moment';

//
// export class NumberFormatValueConverter {
//   toView(value, format) {
//     return numeral(value).format(format);
//   }
// }
//
//
// //import numeral from 'numeral';
//

@inject(ExpressionEvaluator)
export class FieldValueDisplayValueConverter {

  constructor(evaluator){
    this.evaluator = evaluator;
  }

  toView(value, fieldlocator, format, typenarrow) {
    let fl = fieldlocator;
    if (fieldlocator && fieldlocator.indexOf("_{") >= 0){
      fl = fieldlocator.replace(new RegExp('_{', 'g'), '${');
    } else {
      fl = fieldlocator ? '${' + fieldlocator + '}' : undefined;
    }

    let message = fl ? this.evaluator.evaluateInterpolation(fl, value) : undefined;
    //let message = fl ? this.evaluator.evaluateInterpolation('${' + fl + '}', value) : undefined;

    if (typenarrow && message){
      if (typenarrow === 'datetime'){
        // message = new Date(parseInt(message,10));

        if (format){
          message = moment(message).format(format);
        }
      }
    }

    if (!message || ((typeof message) == 'string' && message.length <= 0)){
      message = '--';
    }

    return message;
    //return numeral(value).format(format);
  }
}

export class DateFormatValueConverter {
  toView(value) {
    return moment(value).format('DD/MM/YYYY HH:mm:ss');
  }
}
