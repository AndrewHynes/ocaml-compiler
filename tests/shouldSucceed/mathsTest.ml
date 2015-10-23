open TestHelpers

let tests = [

    ("(Plus 300, 400)", stringToAST "(300 + 400)");
    ("(Plus 300, 400)", stringToAST "300 + 400");
    
    ("700.", stringToOptimisedAST "(300 + 400)");
    ("700.", stringToOptimisedAST "300 + 400");
    
    ("(Plus 3, (Times 5, 7))", stringToAST "3 +5 * 7");
    ("38.", stringToOptimisedAST "3 +5 * 7");


    ("(Print: 3)(Times 1000, 2)", stringToAST "print 3;;;
					       ;;
					       ;
					       ;;;;;
					       1000 * 2");
    ("(Print: 3)2000.", stringToOptimisedAST "print 3;;;
					      ;;
					      ;
					      ;;;;;
					      1000 * 2");

    
    ("(If true, Then (1), Else (2))", stringToAST "if true then 1 else 2");
    ("1", stringToOptimisedAST "if true then 1 else 2");


    ("(If x, Then (1), Else (2))", stringToAST "if x then 1 else 2");
    ("(If x, Then (1), Else (2))", stringToOptimisedAST "if x then 1 else 2")
      
      
  ]

