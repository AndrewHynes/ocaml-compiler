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

let rtTests = [

    ("180\n", (stringToAsm, "100 + (20 * 4) + 1 - 1"));
    ("700\n", (stringToAsm, "(300 + 400)"));
    ("700\n", (stringToAsm, "300 + 400"));
    ("38\n", (stringToAsm, "3 +5 * 7"));
    ("38\n", (stringToOptimisedAsm, "3 +5 * 7"));

    
    ("1\n", (stringToAsm, "if true then 1 else 2"));
    ("1\n", (stringToOptimisedAsm, "if true then 1 else 2"));      

  ]
		
