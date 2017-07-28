/**
 * Created by maksim on 7/13/17.
 */
var tools = require('../../lib/tools');

function clone(obj){
  return JSON.parse(JSON.stringify(obj));
}

var assert = require('assert');

describe('Tools', function(){

  it('replaceLong', function(){

    assert.equal( tools.replaceLong({low: 0, high: 0, unsigned: true}), "0");
    assert.equal( tools.replaceLong({low: 1, high: 0, unsigned: true}), "1");

    assert.equal( tools.replaceLong({low: 2, high: 1, unsigned: true}), "OVERFLOW:2");
    assert.equal( tools.replaceLong({low: 3, high: 0, unsigned: false}), "SIGNED:3");
    assert.equal( tools.replaceLong({low: 4, high: 1, unsigned: false}), "OVERFLOW:4");

    var notLong = {low: 5, high: 1, unsigned: false, me:2};
    assert.deepEqual( tools.replaceLong(notLong), notLong);

  });

  it('getHost', function(){
    assert.equal( tools.getHost('http://localhost:7053/asd'), "localhost:7053");
    assert.equal( tools.getHost('http://localhost:7053'), "localhost:7053");
  });

});



