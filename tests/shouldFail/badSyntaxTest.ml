open TestHelpers

let tests = [
    
    (errorString, stringToAST "1 +
			       2 +
			       !");
    (errorString, stringToOptimisedAST "1 +
					2 +
					!");
    
    (errorString, stringToAST "()");
    (errorString, stringToOptimisedAST "()");

    (errorString, stringToAST "~~~");
    (errorString, stringToOptimisedAST "~~~");

    
    (errorString, stringToAST "print x 3 + 3");
    (errorString, stringToOptimisedAST "print x 3 + 3");

    (errorString, stringToAST "1+");
    (errorString, stringToOptimisedAST "1+");

    (errorString, stringToAST "1-");
    (errorString, stringToOptimisedAST "1-");

    (errorString, stringToAST "1*");
    (errorString, stringToOptimisedAST "1*");

    (errorString, stringToAST "1/");
    (errorString, stringToOptimisedAST "1/");

    (errorString, stringToAST "1>");
    (errorString, stringToOptimisedAST "1>")
      
  ]

let rtTests = [

    (errorString, (stringToAsm, "1 +
				 2 +
				 !"));
    (errorString, (stringToOptimisedAsm, "1 +
					  2 +
					  !"));
    
    (errorString, (stringToAsm, "()"));
    (errorString, (stringToOptimisedAsm, "()"));

    (errorString, (stringToAsm, "~~~"));
    (errorString, (stringToOptimisedAsm, "~~~"));

    
    (errorString, (stringToAsm, "print x 3 + 3"));
    (errorString, (stringToOptimisedAsm, "print x 3 + 3"));

    (errorString, (stringToAsm, "1+"));
    (errorString, (stringToOptimisedAsm, "1+"));

    (errorString, (stringToAsm, "1-"));
    (errorString, (stringToOptimisedAsm, "1-"));

    (errorString, (stringToAsm, "1*"));
    (errorString, (stringToOptimisedAsm, "1*"));

    (errorString, (stringToAsm, "1/"));
    (errorString, (stringToOptimisedAsm, "1/"));
    
    (errorString, (stringToAsm, "1>"));
    (errorString, (stringToOptimisedAsm, "1>"));

    (errorString, (stringToAsm, "x"));
    (errorString, (stringToOptimisedAsm, "x"))

  ]

		
