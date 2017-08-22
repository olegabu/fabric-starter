/**
 * Created by maksim on 7/13/17.
 */
var assert = require('assert');

var helper = require('../../lib-fabric/helper');


describe('Helper', function(){

  it('_extractEnrolmentError', function(){

    var sample1 = 'Error: fabric-ca request register failed with errors [[{"code":0,"message":"Identity \'test22\' is already registered"}]]';
    var sample1Result = {"code":0,"message":"Identity \'test22\' is already registered"};
    assert.deepEqual( helper._extractEnrolmentError(sample1), sample1Result);

    var sample2 = 'Error: fabric-ca request register failed with some error';
    var sample2Result = {"code":null,"message":sample2};
    assert.deepEqual( helper._extractEnrolmentError(sample2), sample2Result);

    var sample4 = 'Error: fabric-ca request register failed with [[{message = with invalid json}]]';
    var sample4Result = {"code":null,"message":"{message = with invalid json}"};
    assert.deepEqual( helper._extractEnrolmentError(sample4), sample4Result);

    var sample3 = 'Error: fabric-ca request register failed with errors [[{"code":400,"message":"Authorization failure"}]]';
    var sample3Result = {"code":400,"message":"Authorization failure"};
    assert.deepEqual( helper._extractEnrolmentError(sample3), sample3Result);

  });


});




/**
 *
 */
function clone(obj){
  return JSON.parse(JSON.stringify(obj));
}