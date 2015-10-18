open TestHelpers

let tests = [

    ("(Lambda (VARIABLES: identifier : x), (Plus 3, 3))", stringToAST "(λ x → 3 + 3)");
    ("(Lambda (VARIABLES: identifier : x), (Plus 3, 3))", stringToAST "(lambda x -> 3 + 3)");

    ("(Lambda (VARIABLES: identifier : x), 6.)", stringToOptimisedAST "(λ x → 3 + 3)");
    ("(Lambda (VARIABLES: identifier : x), 6.)", stringToOptimisedAST "(lambda x -> 3 + 3)");

    ("(Lambda (VARIABLES: identifier : x, identifier : y, identifier : z), 3)", stringToOptimisedAST "(lambda x y z -> 3)");
    ("(Lambda (VARIABLES: identifier : x, identifier : y, identifier : z), 3)", stringToAST "(lambda x y z -> 3)");

    ("(Lambda (VARIABLES: identifier : _), x)", stringToAST "λ _ -> x")
      
]





