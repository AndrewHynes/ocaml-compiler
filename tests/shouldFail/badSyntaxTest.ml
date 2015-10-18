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
    (errorString, stringToOptimisedAST "print x 3 + 3")

      
]

