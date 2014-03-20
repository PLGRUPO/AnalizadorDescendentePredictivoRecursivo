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
    
    test('Input ->  1 ', function () {
      assert.deepEqual(foobar.test("CONST  m =  7,  n = 85; VAR a, b;BEGIN  a = x;  b = 4 END."),'[  {    "type": "=",    "left": {      "type": "Const ID",      "value": "m"    },    "right": {      "type": "NUM",      "value": 7    }  },  {    "type": "=",    "left": {      "type": "Const ID",      "value": "n"    },    "right": {      "type": "NUM",      "value": 85    }  },  {    "type": "Var ID",    "value": "a"  },  {    "type": "Var ID",    "value": "b"  },  [    {      "type": "=",      "left": {        "type": "ID",        "value": "a"      },      "right": {        "type": "ID",        "value": "x"      }    },    {      "type": "=",      "left": {        "type": "ID",        "value": "b"      },      "right": {        "type": "NUM",        "value": 4      }    }  ]]');
    });
    test('Input ->  2 ', function () {
      assert.deepEqual(foobar.test("VAR a, b, c;BEGIN  IF a == 1 THEN  WHILE b <= 5 DO  a = a + 1 END."),'[  {    "type": "Var ID",    "value": "a"  },  {    "type": "Var ID",    "value": "b"  },  {    "type": "Var ID",    "value": "c"  },  [    {      "type": "IF",      "left": {        "type": "==",        "left": {          "type": "ID",          "value": "a"        },        "right": {          "type": "NUM",          "value": 1        }      },      "right": {        "type": "WHILE",        "left": {          "type": "<=",          "left": {            "type": "ID",            "value": "b"          },          "right": {            "type": "NUM",            "value": 5          }        },        "right": {          "type": "=",          "left": {            "type": "ID",            "value": "a"          },          "right": {            "type": "+",            "left": {              "type": "ID",              "value": "a"            },            "right": {              "type": "NUM",              "value": 1            }          }        }      }    }  ]]');
    });
    test('Input ->  3 ', function () {
      assert.deepEqual(foobar.test("VAR x, squ;PROCEDURE square;BEGIN   squ= x * x END; BEGIN   x = 1;   WHILE x <= 10 DO   BEGIN      CALL square;    x = x + 1   END END."),'[  {    "type": "Var ID",    "value": "x"  },  {    "type": "Var ID",    "value": "squ"  },  {    "type": "Procedure",    "value": "square",    "left": [      [        {          "type": "=",          "left": {            "type": "ID",            "value": "squ"          },          "right": {            "type": "*",            "left": {              "type": "ID",              "value": "x"            },            "right": {              "type": "ID",              "value": "x"            }          }        }      ]    ]  },  [    {      "type": "=",      "left": {        "type": "ID",        "value": "x"      },      "right": {        "type": "NUM",        "value": 1      }    },    {      "type": "WHILE",      "left": {        "type": "<=",        "left": {          "type": "ID",          "value": "x"        },        "right": {          "type": "NUM",          "value": 10        }      },      "right": [        {          "type": "CALL",          "value": "square"        },        {          "type": "=",          "left": {            "type": "ID",            "value": "x"          },          "right": {            "type": "+",            "left": {              "type": "ID",              "value": "x"            },            "right": {              "type": "NUM",              "value": 1            }          }        }      ]    }  ]]');
    });
    test('Input ->  4 ', function () {
      assert.deepEqual(foobar.test("BEGIN  r = x;  q = 0;  w = y;  WHILE w <= r DO w = 2 * w;  WHILE w > y DO BEGIN    q = 2 * q;    w = w / 2;    IF w <= r THEN BEGIN      r = r - w;      q = q + 1    END  END END."),'[  [    {      "type": "=",      "left": {        "type": "ID",        "value": "r"      },      "right": {        "type": "ID",        "value": "x"      }    },    {      "type": "=",      "left": {        "type": "ID",        "value": "q"      },      "right": {        "type": "NUM",        "value": 0      }    },    {      "type": "=",      "left": {        "type": "ID",        "value": "w"      },      "right": {        "type": "ID",        "value": "y"      }    },    {      "type": "WHILE",      "left": {        "type": "<=",        "left": {          "type": "ID",          "value": "w"        },        "right": {          "type": "ID",          "value": "r"        }      },      "right": {        "type": "=",        "left": {          "type": "ID",          "value": "w"        },        "right": {          "type": "*",          "left": {            "type": "NUM",            "value": 2          },          "right": {            "type": "ID",            "value": "w"          }        }      }    },    {      "type": "WHILE",      "left": {        "type": ">",        "left": {          "type": "ID",          "value": "w"        },        "right": {          "type": "ID",          "value": "y"        }      },      "right": [        {          "type": "=",          "left": {            "type": "ID",            "value": "q"          },          "right": {            "type": "*",            "left": {              "type": "NUM",              "value": 2            },            "right": {              "type": "ID",              "value": "q"            }          }        },        {          "type": "=",          "left": {            "type": "ID",            "value": "w"          },          "right": {            "type": "/",            "left": {              "type": "ID",              "value": "w"            },            "right": {              "type": "NUM",              "value": 2            }          }        },        {          "type": "IF",          "left": {            "type": "<=",            "left": {              "type": "ID",              "value": "w"            },            "right": {              "type": "ID",              "value": "r"            }          },          "right": [            {              "type": "=",              "left": {                "type": "ID",                "value": "r"              },              "right": {                "type": "-",                "left": {                  "type": "ID",                  "value": "r"                },                "right": {                  "type": "ID",                  "value": "w"                }              }            },            {              "type": "=",              "left": {                "type": "ID",                "value": "q"              },              "right": {                "type": "+",                "left": {                  "type": "ID",                  "value": "q"                },                "right": {                  "type": "NUM",                  "value": 1                }              }            }          ]        }      ]    }  ]]');
    });

    
  
});
