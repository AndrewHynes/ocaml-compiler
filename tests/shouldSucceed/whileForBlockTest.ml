open TestHelpers

let tests = [

    (* WHILE LOOPS *)
    
    ("(While ((Assignment: x = 1))((LessThan x, 10))((While ((Assignment: y = 10))((GreaterThan y, 0))((Print: (Plus x, y))Break((Minus y, 1))((Plus x, 1))", stringToAST "while (let x = 1) x < 10 { while (let y = 10) y > 0 { print x + y; break; loopWith y - 1}; loopWith x + 1 };");
    ("(While ((Assignment: x = 1))((LessThan x, 10))((While ((Assignment: y = 10))((GreaterThan y, 0))((Print: (Plus x, y))Break((Minus y, 1))((Plus x, 1))", stringToOptimisedAST "while (let x = 1) x < 10 { while (let y = 10) y > 0 { print x + y; break; loopWith y - 1}; loopWith x + 1 };");

    ("(While ((Assignment: x = 0))((LessThanOrEqualTo x, 10))((Print: x)((Plus x, 1))", stringToAST "while (let x = 0) x <= 10 { print x; loopWith x + 1 };");
    ("(While ((Assignment: x = 0))((LessThanOrEqualTo x, 10))((Print: x)((Plus x, 1))", stringToOptimisedAST "while (let x = 0) x <= 10 { print x; loopWith x + 1 };");
    
    ("(While ((Assignment: x = 5))((LessThanOrEqualTo x, 10))((Print: x)Break((Plus x, 1))", stringToAST "while (let x = 5) x <= 10 { print x; break; loopWith x + 1};");
    ("(While ((Assignment: x = 5))((LessThanOrEqualTo x, 10))((Print: x)Break((Plus x, 1))", stringToOptimisedAST "while (let x = 5) x <= 10 { print x; break; loopWith x + 1};");
    
    ("(While ((Assignment: x = 0))((LessThan x, 10))((Print: (If (Equals x, 5), Then (x), Else (3223)))((Plus x, 1))", stringToAST "while (let x = 0) x < 10 { print (if x == 5 then x else 3223); loopWith x + 1 };");
    ("(While ((Assignment: x = 0))((LessThan x, 10))((Print: (If (Equals x, 5), Then (x), Else (3223)))((Plus x, 1))", stringToOptimisedAST "while (let x = 0) x < 10 { print (if x == 5 then x else 3223); loopWith x + 1 };");
    
    ("(While ((Assignment: x = 1))((LessThan x, 10))((While ((Assignment: y = 1))((Not (Equals y, 1)))((Print: (Plus x, y))((Minus y, 1))(Print: x)((Plus x, 1))", stringToAST "while (let x = 1) x < 10 { while (let y = 1) !(y == 1) { print x + y; loopWith y - 1}; print x; loopWith x + 1 };");
    ("(While ((Assignment: x = 1))((LessThan x, 10))((While ((Assignment: y = 1))((Not (Equals y, 1)))((Print: (Plus x, y))((Minus y, 1))(Print: x)((Plus x, 1))", stringToOptimisedAST "while (let x = 1) x < 10 { while (let y = 1) !(y == 1) { print x + y; loopWith y - 1}; print x; loopWith x + 1 };");

    ("(While ((Assignment: x = (Minus 5, 4)))((LessThan x, 10))((While ((Assignment: y = 1))((Not (Equals y, 1)))((Print: (Plus x, y))((Minus y, 1))(Print: x)((Plus x, (Minus 2, 1)))", stringToAST "while (let x = (5 - 4)) x < 10 { while (let y = 1) !(y == 1) { print x + y; loopWith y - 1}; print x; loopWith x + (2 - 1) };");
    ("(While ((Assignment: x = 1.))((LessThan x, 10))((While ((Assignment: y = 1))((Not (Equals y, 1)))((Print: (Plus x, y))((Minus y, 1))(Print: x)((Plus x, 1.))", stringToOptimisedAST "while (let x = (5 - 4)) x < 10 { while (let y = 1) !(y == 1) { print x + y; loopWith y - 1}; print x; loopWith x + (2 - 1) };");

    ("(While ((Assignment: x = (Minus 5, 4)))((Not (Equals x, 1)))((Print: x)((Plus x, (Minus 2, 1)))", stringToAST "while (let x = (5 - 4)) !(x == 1) { print x; loopWith x + (2 - 1) };");
    ("", stringToOptimisedAST "while (let x = (5 - 4)) !(x == 1) { print x; loopWith x + (2 - 1)};");
    ("8.", stringToOptimisedAST "while (let x = (5 - 4)) !(x == 1) { print x; loopWith x + (2 - 1)}; 3 + 5");

    ("(Assignment: x = 7)(While ((Assignment: x = 0))((LessThan x, 4))((Print: x)((Plus x, 1))(Plus x, 1)", stringToAST "let x = 7; while(let x = 0) x < 4 { print x; loopWith x + 1}; x + 1");
    ("(While ((Assignment: x = 0))((LessThan x, 4))((Print: x)((Plus x, 1))8.", stringToOptimisedAST "let x = 7; while(let x = 0) x < 4 { print x; loopWith x + 1}; x + 1");

    (* FOR LOOPS *)
    
    (* Testing that for loops properly map into while loops in IR *)
    (stringToAST "let x = 7; while(let x = 0) x < 4 { print x; loopWith x + 1}; x + 1",
     stringToAST "let x = 7; for(let x = 0; x < 4; loopWith x + 1){ print x;}; x + 1");
    (stringToAST "while (let x = 0) x <= 10 { print x; loopWith x + 1 };",
     stringToAST "for (let x = 0; x <= 10; loopWith x + 1) { print x; };");

    (stringToOptimisedAST "let x = 7; while(let x = 0) x < 4 { print x; loopWith x + 1}; x + 1",
     stringToOptimisedAST "let x = 7; for(let x = 0; x < 4; loopWith x + 1){ print x;}; x + 1");
    (stringToOptimisedAST "while (let x = 0) x <= 10 { print x; loopWith x + 1 };",
     stringToOptimisedAST "for (let x = 0; x <= 10; loopWith x + 1) { print x; };");

    ("(Assignment: x = 7)(While ((Assignment: x = 0))((LessThan x, 4))((While ((Assignment: y = 0))((LessThan y, 1))((Print: x)((Plus x, 1))((Plus x, 1))(Plus x, 1)", stringToAST "let x = 7; while(let x = 0) x < 4 { for (let y = 0; y < 1; loopWith x + 1) { print x; }; loopWith x + 1}; x + 1");
    ("(While ((Assignment: x = 0))((LessThan x, 4))((While ((Assignment: y = 0))((LessThan y, 1))((Print: x)((Plus x, 1))((Plus x, 1))8.", stringToOptimisedAST "let x = 7; while(let x = 0) x < 4 { for (let y = 0; y < 1; loopWith x + 1) { print x; }; loopWith x + 1}; x + 1");
   
    ("(While ((Assignment: x = 3))((LessThan x, 10))((Print: x)((Plus x, 1))", stringToAST "for (let x = 3; x < 10; loopWith x + 1) { print x; };");
    ("(While ((Assignment: x = 3))((LessThan x, 10))((Print: x)((Plus x, 1))", stringToOptimisedAST "for (let x = 3; x < 10; loopWith x + 1) { print x; };");

    (* BLOCKS *)
    ("(Assignment: x = 3)(Block ((Assignment: x = 4)(Print: (Plus x, x))))(Plus x, x)", stringToAST "let x = 3; block { let x = 4; print x + x; }; x + x");
    ("(Block ((Assignment: x = 4)(Print: (Plus x, x))))6.", stringToOptimisedAST "let x = 3; block { let x = 4; print x + x; }; x + x");

    ("(Block ((Print: 50)Break(Print: 100)))(Plus 3, 6)", stringToAST "block { print 50; break; print 100; }; 3 + 6");
    ("(Block ((Print: 50)Break(Print: 100)))9.", stringToOptimisedAST "block { print 50; break; print 100; }; 3 + 6");
	
    ("(While ((Assignment: x = 0))((LessThan x, 4))((Block ((Print: x)Break))((Plus x, 1))(Plus 3, 1)", stringToAST "for(let x = 0; x < 4; loopWith x + 1){ block { print x; break; }; }; 3 + 1");
    ("(While ((Assignment: x = 0))((LessThan x, 4))((Block ((Print: x)Break))((Plus x, 1))4.", stringToOptimisedAST "for(let x = 0; x < 4; loopWith x + 1){ block { print x; break; }; }; 3 + 1");
	    
    ("(Block ((Print: 50)Continue))", stringToAST "block {print 50; continue;};");
    ("(Block ((Print: 50)Continue))", stringToOptimisedAST "block {print 50; continue;};");
    
    

  ]

let rtTests = [

    (* WHILE LOOPS *)
    
    ("11\n12\n13\n14\n15\n16\n17\n18\n19\n0\n", (stringToAsm, "while (let x = 1) x < 10 { while (let y = 10) y > 0 { print x + y; break; loopWith y - 1}; loopWith x + 1 };"));
    ("11\n12\n13\n14\n15\n16\n17\n18\n19\n0\n", (stringToOptimisedAsm, "while (let x = 1) x < 10 { while (let y = 10) y > 0 { print x + y; break; loopWith y - 1}; loopWith x + 1 };"));

    ("0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n0\n", (stringToAsm, "while (let x = 0) x <= 10 { print x; loopWith x + 1 };"));
    ("0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n0\n", (stringToOptimisedAsm, "while (let x = 0) x <= 10 { print x; loopWith x + 1 };"));

    ("3223
3223
3223
3223
3223
5
3223
3223
3223
3223
0
", (stringToAsm, "while (let x = 0) x < 10 { print (if x == 5 then x else 3223); loopWith x + 1 };"));
    ("3223
3223
3223
3223
3223
5
3223
3223
3223
3223
0
", (stringToOptimisedAsm, "while (let x = 0) x < 10 { print (if x == 5 then x else 3223); loopWith x + 1 };"));
    
    ("1
2
3
4
5
6
7
8
9
0
", (stringToAsm, "while (let x = 1) x < 10 { while (let y = 1) !(y == 1) { print x + y; loopWith y - 1}; print x; loopWith x + 1 };"));
    ("1
2
3
4
5
6
7
8
9
0
", (stringToOptimisedAsm, "while (let x = 1) x < 10 { while (let y = 1) !(y == 1) { print x + y; loopWith y - 1}; print x; loopWith x + 1 };"));
    
    ("0\n", (stringToAsm, "while (let x = (5 - 4)) !(x == 1) { print x; loopWith x + (2 - 1)};"));
    ("0\n", (stringToAsm, "while (let x = (5 - 4)) !(x == 1) { print x; loopWith x + (2 - 1)};"));
    
    ("8\n", (stringToAsm, "while (let x = (5 - 4)) !(x == 1) { print x; loopWith x + (2 - 1)}; 3 + 5"));
    ("8\n", (stringToOptimisedAsm, "while (let x = (5 - 4)) !(x == 1) { print x; loopWith x + (2 - 1)}; 3 + 5"));

    ("0\n1\n2\n3\n8\n", (stringToAsm, "let x = 7; while(let x = 0) x < 4 { print x; loopWith x + 1}; x + 1"));
    ("0\n1\n2\n3\n8\n", (stringToOptimisedAsm, "let x = 7; while(let x = 0) x < 4 { print x; loopWith x + 1}; x + 1"));

    ("8\n6\n", (stringToAsm, "let x = 3; while(let i = 2) i < 3 { let x = 4; print x + x; loopWith i + 1 }; x + x"));
    ("8\n6\n", (stringToOptimisedAsm, "let x = 3; while(let i = 2) i < 3 { let x = 4; print x + x; loopWith i + 1 }; x + x"));

    (* FOR LOOPS *)

    ("0\n1\n2\n3\n4\n", (stringToAsm, "for(let x = 0; x < 4; loopWith x + 1){ block { print x; break; }; }; 3 + 1"));
    ("0\n1\n2\n3\n4\n", (stringToOptimisedAsm, "for(let x = 0; x < 4; loopWith x + 1){ block { print x; break; }; }; 3 + 1"));

    ("0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n0\n", (stringToAsm, "for (let x = 0; x <= 10; loopWith x + 1) { print x; };"));
    ("0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n0\n", (stringToOptimisedAsm, "for (let x = 0; x <= 10; loopWith x + 1) { print x; };"));

    ("0\n1\n2\n3\n8\n", (stringToAsm, "let x = 7; for(let x = 0; x < 4; loopWith x + 1){ print x;}; x + 1"));
    ("0\n1\n2\n3\n8\n", (stringToOptimisedAsm, "let x = 7; for(let x = 0; x < 4; loopWith x + 1){ print x;}; x + 1"));

    ("0\n1\n2\n3\n8\n", (stringToAsm, "let x = 7; while(let x = 0) x < 4 { for (let y = 0; y < 1; loopWith x + 1) { print x; }; loopWith x + 1}; x + 1"));
    ("0\n1\n2\n3\n8\n", (stringToOptimisedAsm, "let x = 7; while(let x = 0) x < 4 { for (let y = 0; y < 1; loopWith x + 1) { print x; }; loopWith x + 1}; x + 1"));	
    
    (* BLOCKS *)
    
    ("8\n6\n", (stringToAsm, "let x = 3; block { let x = 4; print x + x; }; x + x"));
    ("8\n6\n", (stringToOptimisedAsm, "let x = 3; block { let x = 4; print x + x; }; x + x"));

    ("106\n6\n", (stringToAsm, "let x = 3; block { let x = 4; let y = 2; let z = 100; print x + y + z; }; x + x"));
    ("106\n6\n", (stringToOptimisedAsm, "let x = 3; block { let x = 4; let y = 2; let z = 100; print x + y + z; }; x + x"));

    ("0\n1\n2\n3\n4\n", (stringToAsm, "for(let x = 0; x < 4; loopWith x + 1){ block { print x; break; }; }; 3 + 1"));
    ("0\n1\n2\n3\n4\n", (stringToOptimisedAsm, "for(let x = 0; x < 4; loopWith x + 1){ block { print x; break; }; }; 3 + 1"));

    ("50\n9\n", (stringToAsm, "block { print 50; break; print 100; }; 3 + 6"));
    ("50\n9\n", (stringToOptimisedAsm, "block { print 50; break; print 100; }; 3 + 6"));

    (* CONTINUE *)

    ("7\n", (stringToAsm, "for (let i = 0; i < 32; loopWith i + 1) { continue; }; 4 + 3"));
    ("7\n", (stringToOptimisedAsm, "for (let i = 0; i < 32; loopWith i + 1) { continue; }; 4 + 3"));

    ("0\n1\n2\n7\n", (stringToAsm, "for (let i = 0; i < 3; loopWith i + 1) { print i; continue; }; 4 + 3"));
    ("0\n1\n2\n7\n", (stringToOptimisedAsm, "for (let i = 0; i < 3; loopWith i + 1) { print i; continue; }; 4 + 3"));


  ]

