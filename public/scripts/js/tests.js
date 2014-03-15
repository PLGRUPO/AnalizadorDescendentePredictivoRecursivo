var assert = chai.assert,
    expect = chai.expect,
    should = chai.should(); // Note that should has to be executed

var assert = chai.assert;

var foobar = {
  input1: function() {
    return mainTest(" a = 5;");
  },
 
  localStore: function() {
    if(localStorage){
      return "true";
     
    }else{
      return "false";
      
    }

  }
};


suite('Lexical Analysis ', function() {

    test('Verifying Localstorage   ', function () {   
        assert.deepEqual(foobar.localStore(),'true');
    });
    
    test('Create variable and assign value ', function () {
      assert.deepEqual(foobar.input1(),'{"value":"=","arity":"binary","first":{"value":"a","arity":"name"},"second":{"value":3,"arity":"literal"}}');
    });
});
