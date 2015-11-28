open TestHelpers

let tests = [
    
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

  ]

let rtTests = [

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

    
  ]

