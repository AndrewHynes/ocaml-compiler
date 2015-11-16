open TestHelpers

let tests = [

    ("(Function (name: f), (args: identifier : x), (function body: x))", stringToAST "func f x = { x };");
    ("(Function (name: f), (args: identifier : x), (function body: x))", stringToOptimisedAST "func f x = { x };");

    ("(Function (name: f), (args: identifier : x), (function body: 50))", stringToAST "func f x = { 50 };");
    ("(Function (name: f), (args: identifier : x), (function body: 50))", stringToOptimisedAST "func f x = { 50 };");
    
    ("(Function (name: f), (args: identifier : x), (function body: 50))(FunCall (func: f), (args: 0))", stringToAST "func f x = { 50 }; `f 0'");
    ("(Function (name: f), (args: identifier : x), (function body: 50))(FunCall (func: f), (args: 0))", stringToOptimisedAST "func f x = { 50 }; `f 0'");

    ("(Function (name: g), (args: identifier : x), (function body: x))(Function (name: f), (args: identifier : x), (function body: (FunCall (func: g), (args: 50))))(FunCall (func: f), (args: 0))", stringToAST "func g x = { x }; func f x = { `g 50' }; `f 0'");
    ("(Function (name: g), (args: identifier : x), (function body: x))(Function (name: f), (args: identifier : x), (function body: (FunCall (func: g), (args: 50))))(FunCall (func: f), (args: 0))", stringToOptimisedAST "func g x = { x }; func f x = { `g 50' }; `f 0'");

    ("(Assignment: x = 50)(Function (name: f), (args: identifier : y), (function body: x))(FunCall (func: f), (args: 0))", stringToAST "let x = 50; func f y = { x }; `f 0'");
    ("(Function (name: f), (args: identifier : y), (function body: 50))(FunCall (func: f), (args: 0))", stringToOptimisedAST "let x = 50; func f y = { x }; `f 0'");

  ]

let rtTests = [

    ("50\n", (stringToAsm, "func f x = {50}; `f 0'"));
    ("50\n", (stringToOptimisedAsm, "func f x = {50}; `f 0'"));
    
    ("32\n", (stringToAsm, "func f x = {x}; `f 32'"));
    ("32\n", (stringToOptimisedAsm, "func f x = {x}; `f 32'"));
    
    ("700\n", (stringToAsm, "func f x y = { x + y }; `f 300 400'"));
    ("700\n", (stringToAsm, "func f x y = { x + y }; `f 300 400'"));

    ("100\n", (stringToAsm, "func f x y = { x - y }; `f 300 200'"));
    ("100\n", (stringToAsm, "func f x y = { x - y }; `f 300 200'"));
    
    ("50\n", (stringToAsm, "func g x = { x }; func f x = { `g 50' }; `f 0'"));
    ("50\n", (stringToOptimisedAsm, "func g x = { x }; func f x = { `g 50' }; `f 0'"));

    ("101\n", (stringToAsm, "func g x = { if x == 50 then 100 else 200 }; func f x = { x + `g 50' }; `f 1'"));
    ("101\n", (stringToOptimisedAsm, "func g x = { if x == 50 then 100 else 200 }; func f x = { x + `g 50' }; `f 1'"));

    ("201\n", (stringToAsm, "func g x = { if x == 50 then 100 else 200 }; func f x = { x + `g 23' }; `f 1'"));
    ("201\n", (stringToOptimisedAsm, "func g x = { if x == 50 then 100 else 200 }; func f x = { x + `g 23' }; `f 1'"));      

    ("50\n", (stringToAsm, "let x = 50; func f y = { x }; `f 0'"));
    ("50\n", (stringToOptimisedAsm, "let x = 50; func f y = { x }; `f 0'"));
    
    ("16\n", (stringToAsm, "func f x y z = { let a = 1; let b = 2; let c = 3; let d = 4; a + b + c + d + x + y + z }; `f 1 2 3'"));
    ("16\n", (stringToOptimisedAsm, "func f x y z = { let a = 1; let b = 2; let c = 3; let d = 4; a + b + c + d + x + y + z }; `f 1 2 3'"));

    ("17711\n", (stringToAsm, "func fib x =
			    {
			    if (x <= 2)
			    then 1
			    else (`fib (x - 1)' + `fib (x - 2)')
			    };

			    `fib 22'"));

    ("17711\n", (stringToOptimisedAsm, "func fib x =
					{
					if (x <= 2)
					then 1
					else (`fib (x - 1)' + `fib (x - 2)')
					};
					
					`fib 22'"));

    ("17711\n", (stringToAsm, "let retVal = 1;
			       func fib x =
			       {
			       if (x <= 2)
			       then retVal
			       else (`fib (x - 1)' + `fib (x - 2)')
			       };
			       
			       `fib 22'"));
    
    ("17711\n", (stringToOptimisedAsm, "let retVal = 1;
					func fib x =
					{
					if (x <= 2)
					then retVal
					else (`fib (x - 1)' + `fib (x - 2)')
					};
					
					`fib 22'"));

    
  ]

