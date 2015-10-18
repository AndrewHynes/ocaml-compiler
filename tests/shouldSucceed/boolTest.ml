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
    ("false", stringToOptimisedAST "!(true || false)")
      
]

