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

