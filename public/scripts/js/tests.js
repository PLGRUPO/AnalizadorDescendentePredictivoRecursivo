var assert = chai.assert,
    expect = chai.expect,
    should = chai.should(); // Note that should has to be executed

var assert = chai.assert;

var foobar = {
  input1: function() {
    return mainTest("var a = 3;");
  },
  input2: function() {
    return mainTest("var a = 3; var b= 4; var c = a+b;");
  },
  input3: function() {
    return mainTest("var a = 3; var b= 4; var c = a*b;");
  },
  input4: function() {
    return mainTest("var a = 'hello';  var b = function(x) { var c = 3; return x+c;  };");
  },
  input5: function() {
    return mainTest("var a = 'hello';  var b = function(x) { var c = 3; return x+c;  }; b(4);");
  },
  input6: function() {
    return mainTest("var a/&#@:_;!|! = 'hello';");
  },
  input7: function() {
    return mainTest('var Suma << 5;');
  },
  localStore: function() {
    if(localStorage){
      return "true";
     
    }else{
      return "false";
      
    }

  },
  Url: function() {
    var url = window.location.pathname;
    if (url.indexOf('/test') > -1) {
      return 'true';
      
    }
  } 
};


suite('Lexical Analysis ', function() {
    test('Verifying Url ', function () {   
        assert.deepEqual(foobar.Url(),'true');
    });
    test('Verifying Localstorage   ', function () {   
        assert.deepEqual(foobar.localStore(),'true');
    });
    
    test('Create variable and assign value ', function () {
      assert.deepEqual(foobar.input1(),'{"value":"=","arity":"binary","first":{"value":"a","arity":"name"},"second":{"value":3,"arity":"literal"}}');
    });
    
    test('Operator sum  ', function () {
        assert.deepEqual(foobar.input2(),'[{"value":"=","arity":"binary","first":{"value":"a","arity":"name"},"second":{"value":3,"arity":"literal"}},{"value":"=","arity":"binary","first":{"value":"b","arity":"name"},"second":{"value":4,"arity":"literal"}},{"value":"=","arity":"binary","first":{"value":"c","arity":"name"},"second":{"value":"+","arity":"binary","first":{"value":"a","arity":"name"},"second":{"value":"b","arity":"name"}}}]');
    });
       test('Operator mult  ', function () {
        assert.deepEqual(foobar.input3(),'[{"value":"=","arity":"binary","first":{"value":"a","arity":"name"},"second":{"value":3,"arity":"literal"}},{"value":"=","arity":"binary","first":{"value":"b","arity":"name"},"second":{"value":4,"arity":"literal"}},{"value":"=","arity":"binary","first":{"value":"c","arity":"name"},"second":{"value":"*","arity":"binary","first":{"value":"a","arity":"name"},"second":{"value":"b","arity":"name"}}}]');
    });
    test('Function with return value ', function () {
        assert.deepEqual(foobar.input4(),'[{"value":"=","arity":"binary","first":{"value":"a","arity":"name"},"second":{"value":"hello","arity":"literal"}},{"value":"=","arity":"binary","first":{"value":"b","arity":"name"},"second":{"value":"function","arity":"function","first":[{"value":"x","arity":"name"}],"second":[{"value":"=","arity":"binary","first":{"value":"c","arity":"name"},"second":{"value":3,"arity":"literal"}},{"value":"return","arity":"statement","first":{"value":"+","arity":"binary","first":{"value":"x","arity":"name"},"second":{"value":"c","arity":"name"}}}]}}]');
    });
    
          test('Function with return value and exec ', function () {
        assert.deepEqual(foobar.input5(),'[{"value":"=","arity":"binary","first":{"value":"a","arity":"name"},"second":{"value":"hello","arity":"literal"}},{"value":"=","arity":"binary","first":{"value":"b","arity":"name"},"second":{"value":"function","arity":"function","first":[{"value":"x","arity":"name"}],"second":[{"value":"=","arity":"binary","first":{"value":"c","arity":"name"},"second":{"value":3,"arity":"literal"}},{"value":"return","arity":"statement","first":{"value":"+","arity":"binary","first":{"value":"x","arity":"name"},"second":{"value":"c","arity":"name"}}}]}},{"value":"(","arity":"binary","first":{"value":"b","arity":"name"},"second":[{"value":4,"arity":"literal"}]}]');
    });

       test('Error with invalid Id ', function () {
        assert.deepEqual(foobar.input6(),"\"Syntaxerrornear\'#@:_;!|!=\'hello\';\'\"");
    });
	  test('Error with operator assign  ', function () {
        assert.deepEqual(foobar.input7(),'{"name":"SyntaxError","message":"Unknownoperator.","from":9,"to":11,"value":"&lt;&lt;"}');
    });
});
