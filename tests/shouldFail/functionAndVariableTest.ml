open TestHelpers

let tests = [
    
    (errorString, stringToAST "let x = ~~~; x");
    (errorString, stringToOptimisedAST "let x = ~~~; x");

    
  ]

let rtTests = [

    (errorString, (stringToAsm, "`f 1 2 3'"));
    (errorString, (stringToOptimisedAsm, "`f 1 2 3'"));
    
    (errorString, (stringToAsm, "x + y"));
    (errorString, (stringToOptimisedAsm, "x + y"));

    (errorString, (stringToAsm, "let y = x; let x = 3; y"));
    (errorString, (stringToOptimisedAsm, "let y = x; let x = 3; y"));
    

  ]

		
