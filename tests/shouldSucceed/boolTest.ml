open TestHelpers

let tests = [
    
    ("(Not (And (Not true), false))", stringToAST "!(!true && false)");
    ("true", stringToOptimisedAST "!(!true && false)");

    ("(And true, false)", stringToAST "(true && false)");
    ("false", stringToOptimisedAST "(true && false)");
    
    ("(Not true)", stringToAST "!true");
    ("false", stringToOptimisedAST "!true");
    
    ("(Not false)", stringToAST "!false");
    ("true", stringToOptimisedAST "!false");
    
    ("(Or true, false)", stringToAST "(true || false)");
    ("true", stringToOptimisedAST "(true || false)");
    
    ("(Not (Or true, false))", stringToAST "!(true || false)");
    ("false", stringToOptimisedAST "!(true || false)");

    ("(If (And true, true), Then (1), Else (2))", stringToAST "if true && true then 1 else 2");
    ("1", stringToOptimisedAST "if true && true then 1 else 2");

    ("false", stringToOptimisedAST "((3 /3) * 273 + 231) >= (1222 / 2 + 2121 - 1)");

    ("(GreaterThan 1, 2)", stringToAST "1 > 2");
    ("false", stringToOptimisedAST "1 > 2");

    ("(LessThan 1, 2)", stringToAST "1 < 2");
    ("true", stringToOptimisedAST "1 < 2");

    ("(Equals 1, 1)", stringToAST "1 == 1");
    ("true", stringToOptimisedAST "1 == 1");

    ("(Equals 1, 2)", stringToAST "1 == 2");
    ("false", stringToOptimisedAST "1 == 2");

    ("(GreaterThanOrEqualTo 1, 1)", stringToAST "1 >= 1");
    ("true", stringToOptimisedAST "1 >= 1");

    ("(LessThanOrEqualTo 1, 2)", stringToAST "1 <= 2");
    ("true", stringToOptimisedAST "1 <= 2")


  ]

let rtTests = [

    ("2\n", (stringToAsm, "if 3 > 5 then 1 else 2"));
    ("1\n", (stringToAsm, "if 5 > 3 then 1 else 2"));
    
    ("2\n", (stringToOptimisedAsm, "if 3 > 5 then 1 else 2"));
    ("1\n", (stringToOptimisedAsm, "if 5 > 3 then 1 else 2"));

    ("1\n", (stringToAsm, "!(!true && false)"));
    ("1\n", (stringToOptimisedAsm, "!(!true && false)"));

    ("0\n", (stringToAsm, "(true && false)"));
    ("0\n", (stringToOptimisedAsm, "(true && false)"));
    
    ("0\n", (stringToAsm, "!true"));
    ("0\n", (stringToOptimisedAsm, "!true"));
    
    ("1\n", (stringToAsm, "!false"));
    ("1\n", (stringToOptimisedAsm, "!false"));

    ("1\n", (stringToAsm, "(true || false)"));
    ("1\n", (stringToOptimisedAsm, "(true || false)"));

    ("0\n", (stringToAsm, "!(true || false)"));
    ("0\n", (stringToOptimisedAsm, "!(true || false)"));

    ("1\n", (stringToAsm, "if true && true then 1 else 2"));
    ("1\n", (stringToOptimisedAsm, "if true && true then 1 else 2"));

    ("0\n", (stringToAsm, "((3 /3) * 273 + 231) >= (1222 / 2 + 2121 - 1)"));
    ("0\n", (stringToOptimisedAsm, "((3 /3) * 273 + 231) >= (1222 / 2 + 2121 - 1)"));

    ("0\n", (stringToAsm, "1 > 2"));
    ("0\n", (stringToOptimisedAsm, "1 > 2"));
    
    ("1\n", (stringToAsm, "1 < 2"));
    ("1\n", (stringToOptimisedAsm, "1 < 2"));

    ("1\n", (stringToAsm, "1 == 1"));
    ("1\n", (stringToOptimisedAsm, "1 == 1"));

    ("0\n", (stringToAsm, "1 == 2"));
    ("0\n", (stringToOptimisedAsm, "1 == 2"));


    ("1\n", (stringToAsm, "1 >= 1"));
    ("1\n", (stringToOptimisedAsm, "1 >= 1"));

    
    ("1\n", (stringToAsm, "1 <= 2"));
    ("1\n", (stringToOptimisedAsm, "1 <= 2"))
     
  ]

