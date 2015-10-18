open TestHelpers

let tests = [

    (* Though this shouldn't strictly compile, it should 
       still parse correctly *)
    ("(Assignment: x = 3)(Assignment: y = (Plus x, z))(Print: y)", stringToAST "let x = 3; let y = x + z; print y;
");
    ("(Assignment: x = 3)(Assignment: y = (Plus x, z))(Print: y)", stringToOptimisedAST "let x = 3; let y = x + z; print y;
");
    
    ("(Assignment: x = (Plus 300, 500))", stringToAST "let x = 300 + 500;");
    ("(Assignment: x = 800.)", stringToOptimisedAST "let x = 300 + 500;");
      
    ("(Assignment: x = 3)(Assignment: y = 8)(Print: (Plus x, y))", stringToAST "let x = 3;let y = 8;print (x + y);");
    ("(Assignment: x = 3)(Assignment: y = 8)(Print: (Plus x, y))", stringToOptimisedAST "let x = 3;let y = 8;print (x + y);");

    ("(Assignment: double = identifier : x, (function body: (Times x, 2)))", stringToAST "let double = lambda x -> x * 2;");
    ("(Assignment: double = identifier : x, (function body: (Times x, 2)))", stringToOptimisedAST "let double = lambda x -> x * 2;")

]

