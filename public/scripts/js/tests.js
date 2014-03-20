var assert = chai.assert,
    expect = chai.expect,
    should = chai.should(); // Note that should has to be executed

var assert = chai.assert;

var foobar = {

  localStore: function() {
    if(localStorage){
      return "true";
     
    }else{
      return "false";
      
    }
  },
  test: function(text) {
    return test_main(text);
  }
};


suite('Lexical Analysis ', function() {

    test('Verifying Localstorage   ', function () {   
        assert.deepEqual(foobar.localStore(),'true');
    });
    
    test('Input ->  a = 5 ', function () {
      assert.deepEqual(foobar.test("a = 5"),'{  "type": "=",  "left": {    "type": "ID",    "value": "a"  },  "right": {    "type": "NUM",    "value": 5  }}');
    });
    test('Input ->  a = 5 ', function () {
      assert.deepEqual(foobar.test("CONST x = 0; \nVAR a, b, c;"),'{  "type": "=",  "left": {    "type": "ID",    "value": "a"  },  "right": {    "type": "NUM",    "value": 5  }}');
    });
    test('Input ->  a = 5 ', function () {
      assert.deepEqual(foobar.test("a = 5"),'{  "type": "=",  "left": {    "type": "ID",    "value": "a"  },  "right": {    "type": "NUM",    "value": 5  }}');
    });
    test('Input ->  a = 5 ', function () {
      assert.deepEqual(foobar.test("a = 5"),'{  "type": "=",  "left": {    "type": "ID",    "value": "a"  },  "right": {    "type": "NUM",    "value": 5  }}');
    });

    
  
});
