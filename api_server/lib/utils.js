/**
 * Created by maksim on 7/15/17.
 */
"use strict";

module.exports = {
  replaceBuffer:replaceBuffer,
  replaceLong:replaceLong,
  isObject:isObject
};


/**
 * @param {*} obj
 * @returns {boolean} true when obj is an object
 */
function isObject(obj) {
  return obj !== null && typeof obj === 'object';
}

/**
 * Replace 'Buffer' type with it's value, so it become an ordinary string
 * @param {*} data
 * @returns {*} data with 'Buffer' replaced with base64 encoded buffer value
 */
function replaceBuffer(data){
  if(isObject(data)){
    if (data instanceof Buffer){
      data = data.toString('base64');
    } else {
      Object.keys(data).forEach(function(propery){
        data[propery] = replaceBuffer(data[propery]);
      });
    }
  }
  return data;
}

/**
 * Replace protobuf 'Long' type with a string
 * @param {*} data
 * @returns {*} data with 'Long' represented as string
 */
function replaceLong(data){
  // TODO: replaceLong not implemented
  return data;
}
