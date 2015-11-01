open TestHelpers

let tests = [

    (* Though this shouldn't strictly compile, it should 
       still parse correctly *)
    ("(Assignment: x = 3)(Assignment: y = (Plus x, z))(Print: y)", stringToAST "let x = 3; let y = x + z; print y;
");
    ("(Assignment: y = (Plus 3, z))(Print: y)", stringToOptimisedAST "let x = 3; let y = x + z; print y;
");
    
    ("(Assignment: x = (Plus 300, 500))", stringToAST "let x = 300 + 500;");
    ("", stringToOptimisedAST "let x = 300 + 500;");

    ("(Assignment: x = (Plus 300, 500))(Assignment: y = (Plus 100, 200))", stringToAST "let x = 300 + 500; let y = 100 + 200;");
    ("", stringToOptimisedAST "let x = 300 + 500; let y = 100 + 200;");
    
    ("(Assignment: x = 3)(Assignment: y = 8)(Print: (Plus x, y))", stringToAST "let x = 3;let y = 8;print (x + y);");
    ("(Print: 11.)", stringToOptimisedAST "let x = 3;let y = 8;print (x + y);");

    ("(Assignment: double = identifier : x, (function body: (Times x, 2)))", stringToAST "let double = lambda x -> x * 2;");
    ("(Assignment: double = identifier : x, (function body: (Times x, 2)))", stringToOptimisedAST "let double = lambda x -> x * 2;");

    ("(Assignment: b = (GreaterThan 3, 5))(If b, Then (1), Else (2))", stringToAST "let b = 3 > 5; if b then 1 else 2");
    ("(Assignment: b = (GreaterThan 5, 3))(If b, Then (1), Else (2))", stringToAST "let b = 5 > 3; if b then 1 else 2")


]


let rtTests = [

    ("800\n", (stringToAsm, "let x = 300 + 500; x"));
    ("800\n", (stringToOptimisedAsm, "let x = 300 + 500; x"));

    ("1100\n", (stringToAsm, "let x = 300 + 500; let y = 100 + 200; x + y"));
    ("1100\n", (stringToOptimisedAsm, "let x = 300 + 500; let y = 100 + 200; x + y"));

    ("2\n", (stringToAsm, "let b = 3 > 5; if b then 1 else 2"));
    ("1\n", (stringToAsm, "let b = 5 > 3; if b then 1 else 2"));
    ("2\n", (stringToOptimisedAsm, "let b = 3 > 5; if b then 1 else 2"));
    ("1\n", (stringToOptimisedAsm, "let b = 5 > 3; if b then 1 else 2"));

      
    ("500\n", (stringToOptimisedAsm, "let x = 20; 300 + 200"))
    
  ]
		

	      
