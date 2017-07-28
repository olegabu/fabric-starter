/**
 * Created by maksim on 7/15/17.
 */
"use strict";

var fs = require('fs');

module.exports = {
  replaceBuffer   : replaceBuffer,
  replaceLong     : replaceLong,
  isObject        : isObject,
  getHost         : getHost,
  readFilePromise : readFilePromise
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
  if(isObject(data)){

    /* jshint -W014 */
    var isLong = typeof data.low !== "undefined"
      && typeof data.high !== "undefined"
      && typeof data.unsigned !== "undefined"
      && Object.keys(data).length === 3;

    if (isLong){
      // console.log(data);
      // TODO: deal with data.unsigned and data.hight
      if(data.high){
        console.warn('replaceLong: high part is not supported yet');
        data = 'OVERFLOW:'+data.low;
      } else if(!data.unsigned){
        console.warn('replaceLong: signed is not supported yet');
        data = 'SIGNED:'+data.low;
      } else {
        data = (data.high||'')+''+data.low;
      }

    } else {
      Object.keys(data).forEach(function(propery){
        data[propery] = replaceLong(data[propery]);
      });
    }
  }
  return data;
}


/**
 * Extract host+port from url
 * @param {string} url
 * @return {string}
 */
function getHost(url){
  //                             1111       222222
  var m = (url||"").match(/^(\w+:)?\/\/([^\/]+)/) || [];
  return m[2];
}



function readFilePromise (file) {
  return new Promise(function(resolve, reject){
    fs.readFile(file, function (err, data) {
      return !err
        ? resolve(data)
        : reject(err);
    });
  });
}



